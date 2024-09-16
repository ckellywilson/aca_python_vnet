import cups
import os
import time
from django.http import HttpResponse
from django.shortcuts import render
from django.template.loader import render_to_string
from .models import MyModel  # Import your model

# Create your views here.

def my_view(request):
    data = MyModel.objects.all()
    return render(request, 'my_template.html', {'data': data})

def print_view(request):
    # Render the HTML content
    html_content = render_to_string('my_template.html', {'data': MyModel.objects.all()})
    
    # Save the HTML content to a temporary file
    html_file_path = '/tmp/print_job.html'
    with open(html_file_path, 'w', encoding='UTF8') as html_file:
        html_file.write(html_content)
    
    # Convert HTML to PDF using CUPS-PDF
    conn = cups.Connection()
    printers = conn.getPrinters()
    pdf_printer_name = None

    # Find the CUPS-PDF printer
    for printer in printers:
        if 'pdf' in printer.lower():
            pdf_printer_name = printer
            break

    if not pdf_printer_name:
        return HttpResponse('CUPS-PDF printer not found', status=500)

    # Print the HTML file to PDF
    pdf_output_dir = '/root/PDF'
    conn.printFile(pdf_printer_name, html_file_path, "Print mySQL table", {"sides": "two-sided-long-edge", "prettyprint": "True"})

    # Wait for any PDF file to be generated
    timeout = 30  # seconds
    start_time = time.time()
    pdf_file_path = None
    while time.time() - start_time <= timeout:
        pdf_files = [f for f in os.listdir(pdf_output_dir) if f.endswith('.pdf')]
        if pdf_files:
            pdf_file_path = os.path.join(pdf_output_dir, pdf_files[0])
            break
        time.sleep(1)  # Sleep for 1 second before checking again

    # Read the PDF file and return it in the HTTP response
    with open(pdf_file_path, 'rb') as pdf_file:
        response = HttpResponse(pdf_file.read(), content_type='application/pdf')
        response['Content-Disposition'] = 'attachment; filename="root_PDF.pdf"'
    
    # Clean up the temporary files
    os.remove(html_file_path)
    os.remove(pdf_file_path)
    
    return response