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