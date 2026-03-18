# 🚀 EKS Terraform Setup

This project provisions an AWS EKS (Elastic Kubernetes Service) cluster using Terraform and deploys applications using kubectl.

---

## 📌 Prerequisites

- Minimum Instance: 2 CPU & 4GB RAM  
  Example: t2.medium or c7i-flex.large  
- OS: Ubuntu/Linux  

---

## ⚙️ Install Dependencies

### 1️⃣ AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

Configure AWS:
aws configure
Docs: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


Provide:
Access Key
Secret Key
Region (e.g., us-east-1)

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform