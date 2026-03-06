# Cloud Resume Challenge – Azure Implementation

## Overview

This project is my implementation of the **Cloud Resume Challenge using Microsoft Azure**.  
The goal of this project is to demonstrate practical cloud engineering skills by building and deploying a resume website with a fully automated cloud infrastructure.

The project combines:

- Frontend development (HTML, CSS, JavaScript)
- Backend development (Python)
- Cloud infrastructure on Microsoft Azure
- Infrastructure as Code (Terraform)
- CI/CD pipelines using GitHub Actions

The result is a fully automated, cloud-hosted resume website with a visitor counter backed by a serverless API and database.

---

## Architecture

The solution uses several Azure services working together:

- **Azure Storage Account**
  - Hosts the static resume website.

- **Azure Functions**
  - Serverless API that handles visitor counter requests.

- **Azure Storage Account (Table Storage)**
  - Stores the visitor count in a Storage Table.

- **Terraform**
  - Defines and deploys the Azure infrastructure.

- **GitHub Actions**
  - Automates deployment and CI/CD.

---

## Project Structure

```
cloud-resume/
│
├── .github/
│   └── workflows/
│       └── deploy-function.yml      # CI/CD pipeline for Azure Function
│
├── http_trigger/                    # Azure Function source code
│   ├── __init__.py
│   ├── function.json
│   └── requirements.txt
│
├── modules/                         # Terraform modules
│   ├── function
│   ├── static_site
│       └── site                     # Code for the static website
│
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Terraform variables
├── outputs.tf                       # Terraform outputs
├── providers.tf                     # Provider configuration
├── versions.tf                      # Terraform version constraints
│
└── README.md
```

---

## Features

### Static Resume Website

The resume is built using:

- HTML
- CSS
- JavaScript

It is deployed as a **static website using Azure Storage**.

---

### Visitor Counter

The website includes a **visitor counter** that:

1. Sends a request from JavaScript to an API.
2. The API is implemented with **Azure Functions (Python)**.
3. The function reads and updates a value stored in **Table storage**.

This architecture ensures the frontend does not communicate directly with the database.

---

### Infrastructure as Code

All Azure resources are defined using **Terraform**.

Benefits include:

- Repeatable infrastructure deployments
- Version control for infrastructure
- Automated provisioning
- Reduced manual configuration

Resources deployed include:

- Resource Group
- Storage Account
- Azure Function App
- Supporting services

---

### CI/CD Pipelines

The project uses three **GitHub Actions** pipelines for continuous integration and deployment.

The deploy-to-function-app pipeline performs the following steps:

1. Trigger on push to the `main` branch, pull requests to `main` branch and changes on path **'http_trigger/**'**
2. Checkout repository
3. Login to Azure
4. Install Python dependencies
5. Package Azure Function
6. Deploy to Azure Function App

This ensures that any updates to the backend code are automatically deployed.
---
The deploy-static-website pipeline performs the following steps:
1.  Trigger on push to the `main` branch, pull requests to `main` branch and changes on path **'modules/static_site/site/**'**
2. Checkout repository
3. Upload static site files to azure $web container
4. Purge CDN endpoint
5. Azure logout

This ensures that any updates to the frontend code are automatically deployed.
---
The tf-plan-apply pipeline performs the following steps:

1. Trigger on push to the `main` branch, pull requests to `main` branch and ignores changes on paths related to README, Azure Functions code and static website source code  
2. Checkout repository  
3. Setup Terraform CLI  
4. Terraform init  
5. Terraform format check  
6. Terraform plan generation  
7. Publish Terraform plan as artifact and workflow summary  
8. Comment Terraform plan on pull requests  
9. If changes are detected and the commit is on `main`, download the saved plan and run Terraform apply  

This ensures that any infrastructure changes are validated, reviewed, and automatically deployed to Azure using Terraform.
---
## Technologies Used

- **Microsoft Azure**
- **Terraform**
- **Python**
- **JavaScript**
- **HTML / CSS**
- **GitHub Actions**
- **Azure Functions**
- **Azure Storage**
- **https://github.com/jonathan-vella/azure-agentic-infraops**

---

## Security Considerations

- Azure credentials are stored in **GitHub Secrets**
- No credentials are stored in source control
- Access to Azure is handled via **service principal authentication**

---

## Learning Outcomes

This project helped me gain hands-on experience with:

- Designing cloud architecture
- Deploying serverless applications
- Managing infrastructure with Terraform
- Implementing CI/CD pipelines
- Integrating frontend and backend services in Azure


---

## Future Improvements

Possible improvements include:

- Adding monitoring with Azure Application Insights

---
