# 🎮 The Little Gamestore — Learning Terraform

This repo holds hands-on Terraform lessons. We build an online game shop step by step on **AWS** and **STACKIT**.
Goal: **HashiCorp Certified Terraform Associate (004)** and the skills to build real module-based infrastructure.

## How each lesson works

1. 🎯 **Mission**: what we add to the shop
2. 🛠 **Build on AWS**: session 1
3. 🛠 **Build on STACKIT**: session 2
4. 🧠 **Theory**: short, after you've written the code
5. 📝 **Exam corner**: questions in Associate 004 style
6. 🧪 **Challenge**: optional extra practice
7. 🧹 **Destroy**: always clean up

## Progress

| # | Lesson | AWS | STACKIT |
|---|--------|:---:|:-------:|
| **Part A: Fundamentals** ||||
| 01 | Setup & first resource: the shop's logo bucket | ⬜ | ⬜ |
| 02 | The storefront: static website | ⬜ | ⬜ |
| 03 | Make it configurable: variables, locals, outputs | ⬜ | ⬜ |
| 04 | Network for the shop | ⬜ | ⬜ |
| 05 | The first app server | ⬜ | ⬜ |
| **Part B: Real infrastructure** ||||
| 06 | Remote state & locking | ⬜ | ⬜ |
| 07 | The catalog database + secrets | ⬜ | ⬜ |
| 08 | Scaling out: load balancer | ⬜ | ⬜ |
| 09 | Read the game catalog from YAML/JSON | ⬜ | ⬜ |
| **Part C: Modules** ||||
| 10 | Your first module | ⬜ | ⬜ |
| 11 | Modules talking to modules + remote state | ⬜ | ⬜ |
| 12 | Registry modules & versioning | ⬜ | ⬜ |
| 13 | Environments: dev & prod | ⬜ | ⬜ |
| **Part D: Operations & certification** ||||
| 14 | Day-2: import, moved, removed, debugging | ⬜ | ⬜ |
| 15 | Bonus: Kubernetes (EKS / SKE) + Python app | ⬜ | ⬜ |
| 16 | HCP Terraform | ⬜ | ⬜ |
| 17 | Mock exam | ⬜ | ⬜ |

## Layout

```
lessons/NN-name/
  LESSON.md   # mission, steps, theory, exam questions
  aws/        # your AWS code
  stackit/    # your STACKIT code
modules/      # reusable modules (from lesson 10)
gamestore/    # final combined shop (later)
```

## Cheat sheet (grows each lesson)

```bash
terraform init        # download providers, set up backend
terraform fmt         # format code
terraform validate    # check syntax & internal consistency
terraform plan        # preview changes
terraform apply       # make changes
terraform destroy     # delete everything in this config
```
