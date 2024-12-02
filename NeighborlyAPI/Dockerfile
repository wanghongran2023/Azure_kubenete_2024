FROM mcr.microsoft.com/azure-functions/python:4-python3.9
WORKDIR /home/site/wwwroot
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

