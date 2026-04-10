# 🚀 AWS NAT Gateway Audit & Cleanup Script

## 🔍 Overview

This project provides a **production-ready Bash script** to identify, review, and clean up unused AWS NAT Gateways — helping reduce unnecessary cloud costs.

NAT Gateways can silently increase AWS billing if left unused. This script ensures **visibility + controlled cleanup**.

---

## 🎯 Key Features

✅ Fetch all NAT Gateways in a region
✅ Identify **active (costing)** NAT Gateways
✅ Detect **unused / deleted / failed** NAT Gateways
✅ Clear separation of results using `##########`
✅ Manual confirmation before deletion (safe for production)
✅ Easy to extend for multi-region automation

---

## 🛠️ Tech Stack

* 🐚 Bash Scripting
* ☁️ AWS CLI
* 🧩 jq (JSON parsing)

---

## ⚙️ Prerequisites

Make sure you have:

```bash
aws configure
jq installed
```

---

## 🚀 How to Use

```bash
chmod +x NAT.sh
./NAT.sh <region>
```

### Example:

```bash
./NAT.sh ap-south-1
```

---

## 📊 Sample Output

```bash
########## NAT GATEWAYS IN USE (COSTING MONEY) ##########
NAT_ID: nat-12345 | SUBNET: subnet-abc | VPC: vpc-xyz
------------------------------------------------------
Total NAT Gateways IN USE: 1

########## UNUSED / DELETED NAT GATEWAYS ##########
NAT_ID: nat-67890 | STATE: deleted
------------------------------------------------------
Total UNUSED NAT Gateways: 1
```

---

## ⚠️ Important Notes

* This script **does NOT automatically delete active NAT Gateways**
* Always review before deletion
* Ensure no production workload depends on NAT before removing

---

## 💡 Real-World Use Case

* Cloud cost optimization 💰
* Infrastructure cleanup 🧹
* Audit before production changes 🔍

---

## 🚧 Future Enhancements

* Multi-region support 🌍
* Tag-based filtering (prod/dev)
* Cost estimation integration
* Slack / Email alerts

---

## 👨‍💻 Author

**Aman Srivastava**

Devops Engineer | Cloud | Automation

---

## ⭐ Support

If you found this useful:

* ⭐ Star the repo
* 🔁 Share with your network
* 💬 Connect for collaboration

---

> ⚡ "Automate smartly, save costs, and build scalable cloud systems."
