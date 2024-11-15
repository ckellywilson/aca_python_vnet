from flask import Flask, jsonify, request, render_template, abort,send_file
from flask_sqlalchemy import SQLAlchemy
from flask_wtf.csrf import CSRFProtect
from azure.monitor.opentelemetry import configure_azure_monitor
import os
import cups
import time
import datetime
import logging
# Load environment variables from .env file
from dotenv import load_dotenv

app = Flask(__name__)
csrf = CSRFProtect(app)

load_dotenv()

if(os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING")):
    configure_azure_monitor(logging_name="ipod")

# Configure logging
logging.basicConfig(level=logging.INFO)
logging.log(logging.INFO, "Starting the Flask application")

# Database configuration
def build_connection_string():
    if os.getenv("MYSQL_DATABASE"):
        return (
            f"mysql+pymysql://{os.getenv('MYSQL_USER')}:{os.getenv('MYSQL_PASSWORD')}"
            f"@{os.getenv('MYSQL_HOST')}:{os.getenv('MYSQL_PORT')}/{os.getenv('MYSQL_DATABASE')}"
        )
    return "sqlite:///test.db"

app.config["SQLALCHEMY_DATABASE_URI"] = build_connection_string()
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'mysecretkey')

engine_options = {"connect_args": {"ssl_ca": os.getenv("MYSQL_SSL_CA")}} if os.getenv("MYSQL_SSL_CA") else {}

db = SQLAlchemy(app, engine_options=engine_options)

# Define a model
class MyModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=False, nullable=False)
    description = db.Column(db.String(80), unique=False, nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, server_default=db.func.now(), default=datetime.datetime.now(datetime.timezone.utc))

    def __repr__(self):
        return f"<Model {self.id} {self.name} {self.description}>"

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'created_at': self.created_at
        }   


# Create the database tables
with app.app_context():
    db.create_all()
    db.session.add(MyModel(name="foo", description="about foo"))
    db.session.commit()

# Define routes
@app.route("/")
def index():
    data = MyModel.query.all()
    logging.log(logging.INFO, "Data fetched")
    return render_template("my_template.html", data= data)


@app.route("/data", methods=["POST"])
def create_data():
    data = request.get_json()
    new_data = MyModel(name=data["name"], description=data["description"])
    db.session.add(new_data)
    db.session.commit()
    return jsonify(message="Data created"), 201

@app.route("/print", methods=["POST"])
def print_view():
    html_file_path = None
    pdf_file_path = None
    try:
        # Render the HTML content
        data = MyModel.query.all()
        html_content = render_template("my_template.html", data=data)
        logging.log(logging.INFO, "HTML content rendered")

        # Save the HTML content to a temporary file
        html_file_path = "/tmp/print_job.html"
        with open(html_file_path, "w", encoding="UTF8") as html_file:
            html_file.write(html_content)
        
        logging.log(logging.INFO, "HTML content saved to file %s", html_file_path)

        # Convert HTML to PDF using CUPS-PDF
        conn = cups.Connection()
        printers = conn.getPrinters()
        pdf_printer_name = None

        logging.log(logging.INFO, "Available printers: %s", printers)

        # Find the CUPS-PDF printer
        for printer in printers:
            if "pdf" in printer.lower():
                pdf_printer_name = printer
                break

        if not pdf_printer_name:
            abort(500, description="CUPS-PDF printer not found")
            return

        logging.log(logging.INFO, "CUPS-PDF printer found: %s", pdf_printer_name)

        # Print the HTML file to PDF
        pdf_output_dir = "/root/PDF"
        conn.printFile(
            pdf_printer_name,
            html_file_path,
            "Print mySQL table",
            {"sides": "two-sided-long-edge", "prettyprint": "True"},
        )

        # Wait for any PDF file to be generated
        timeout = 30  # seconds
        start_time = time.time()
        pdf_file_path = None
        while time.time() - start_time <= timeout:
            if os.path.exists(pdf_output_dir):
                pdf_files = [f for f in os.listdir(pdf_output_dir) if f.endswith(".pdf")]
                if pdf_files:
                    pdf_file_path = os.path.join(pdf_output_dir, pdf_files[0])
                    break
            time.sleep(1)  # Sleep for 1 second before checking again

        logging.log(logging.INFO, "PDF file generated: %s", pdf_file_path)

        # Read the PDF file and return it in the HTTP response
        return send_file(
            pdf_file_path,
            mimetype="application/pdf",
            as_attachment=True,
            download_name="printout.pdf"
        )
    except Exception as e:
        abort(500, description=str(e))
        return
    finally:
        db.session.close()
        # Clean up the temporary files
        # if html_file_path and os.path.exists(html_file_path):
        #     os.remove(html_file_path)
        #     os.remove(pdf_file_path)


@app.route("/data", methods=["GET"])
def get_data():
    data = MyModel.query.all()
    logging.log(logging.INFO, "Data fetched")
    return jsonify(data=[d.to_dict() for d in data])

if __name__ == "__main__":
    app.run()