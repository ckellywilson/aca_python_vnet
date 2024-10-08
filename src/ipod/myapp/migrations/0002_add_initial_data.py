# Generated by Django 3.2.25 on 2024-09-09 21:12

from django.db import migrations

def add_initial_data(apps, schema_editor):
    MyModel = apps.get_model('myapp', 'MyModel')
    MyModel.objects.create(name='Initial Name 1', description='Initial Description 1')
    MyModel.objects.create(name='Initial Name 2', description='Initial Description 2')


class Migration(migrations.Migration):

    dependencies = [
        ('myapp', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(add_initial_data),
    ]
