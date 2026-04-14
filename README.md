# 🚀 DevOps Automation Scripts Collection

A curated collection of **real-world DevOps & Cloud automation scripts** designed for monitoring, security, cost optimization, and operational efficiency.

These scripts are built with a **production mindset**, focusing on:

* Reusability
* Safety (dry-run, validation)
* Observability (logging & alerts)
* Interview & real-world readiness

---

## 📂 Scripts Included

### 1. 🔥 Automated EC2 Backup Script

Automates **EBS snapshot creation** for EC2 instances.

**Key Features:**

* Backup all attached volumes
* Tag-based identification
* Reusable across regions
* Supports automation via cron

---

### 2. ⚙️ Auto Scaling Health Check Script

Ensures **self-healing infrastructure** in Auto Scaling Groups.

**Key Features:**

* Monitors instance health & state
* Marks unhealthy instances
* Waits (grace period) before action
* Safe termination with re-validation

---

### 3. 📦 Log Rotation & Cleanup Script

Manages log files efficiently to prevent disk issues.

**Key Features:**

* Size-based log rotation
* Compression for storage optimization
* Retention-based cleanup
* Safe handling of active logs

---

### 4. 🌐 Website / API Health Monitoring Script

Monitors availability of websites or APIs.

**Key Features:**

* HTTP status code validation
* Retry mechanism to avoid false alerts
* Logging for downtime tracking
* Easily extendable to alerts (Slack/SNS)

---

### 5. 🔐 SSL Certificate Expiry Checker

Prevents downtime due to expired SSL certificates.

**Key Features:**

* Fetches certificate expiry date
* Calculates remaining validity
* Threshold-based alerting
* Supports any domain

---

### 6. 📊 Server Resource Monitoring Script

Tracks system performance in real-time.

**Key Features:**

* CPU, Memory, Disk monitoring
* Threshold-based alerting
* Logging for critical events
* Lightweight and cron-friendly

---

### 7. 🔑 IAM Access Key Rotation Script

Enhances security by rotating IAM access keys.

**Key Features:**

* Detects old access keys
* Dry-run and safe rotation mode
* Creates new keys & deactivates old ones
* Supports secure automation practices

---

### 8. 🧹 Unused Resource Cleanup Script

Optimizes cloud costs by removing unused resources.

**Key Features:**

* Tag-based safe deletion (`Cleanup=true`)
* Dry-run and confirmation mode
* Multi-resource cleanup:

  * EBS Volumes
  * Elastic IPs
  * Snapshots
  * AMIs
  * Network Interfaces

---

### 9. 🌉 NAT Gateway Usage Check & Cleanup Script

Identifies and removes unused NAT Gateways to reduce costs.

**Key Features:**

* Detects NAT Gateways with no active traffic
* Validates usage before deletion
* Supports dry-run mode
* Prevents accidental deletion

---

## 🛠️ Prerequisites

* AWS CLI configured (`aws configure`)
* Required IAM permissions based on script usage
* Linux environment (recommended)
* Tools:

  * `jq` (for JSON parsing, if applicable)
  * `bc` (for calculations)
  * `curl`, `openssl`

---

## ▶️ Usage

Make script executable:

```bash
chmod +x script.sh
```

Run script:

```bash
./script.sh <arguments>
```

Each script contains:

* Input details
* Execution example
* Expected output

---

## ⚠️ Important Notes

* Always use **dry-run mode** before actual execution
* Ensure proper **IAM permissions**
* Test in **non-production environments first**
* Use **tag-based filtering** for safe operations

---

## 💡 Best Practices Followed

* Input validation
* Error handling
* Logging for observability
* Modular and reusable functions
* Production-safe approaches

---

## 🧠 Learning Outcome

This repository helps you:

* Understand **real-world DevOps automation**
* Build **production-ready scripts**
* Prepare for **DevOps & SRE interviews**
* Create a strong **GitHub portfolio**

---

## 🚀 Future Enhancements

* Integration with alerting systems (Slack, Email, SNS)
* Event-driven automation (Lambda, EventBridge)
* Dashboard-based monitoring
* Multi-account automation

---

## 🤝 Contribution

Feel free to:

* Enhance scripts
* Add new automation use cases
* Improve security & performance

---

## ⭐ Final Thought

> “Automation is not just about making things work — it’s about making them safe, scalable, and reliable.”

---
