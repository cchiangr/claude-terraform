# Lesson 01: Setup & First Resource 🪣

## 🎯 Mission

The Little Gamestore needs somewhere to keep its brand assets. Your first job is to create a **storage bucket** and upload the shop's **logo** into it, using Terraform only (no clicking in the console).

By the end of this lesson you'll have:
- working credentials for AWS
- a bucket with a globally unique name
- `logo.svg` stored in that bucket
- a full `init → plan → apply → destroy` cycle done

---

## Part 1: AWS

### Step 0: Create AWS access (one time)

For learning, use a dedicated IAM user. Don't use your root account.

1. Sign in to the AWS console as root or as an admin.
2. **IAM → Users → Create user** → name: `carlos-cli`.
3. Permissions: **Attach policies directly** → `AdministratorAccess`.
   *(Broad, but fine for a personal learning account. In real projects you'd use least privilege.)*
4. Open the user → **Security credentials → Create access key** → use case "Command Line Interface (CLI)".
5. In your terminal:
   ```bash
   aws configure --profile carlos-cli
   # Access key ID:      <paste>
   # Secret access key:  <paste>
   # Default region:     eu-central-1
   # Output format:      json
   ```
6. Check that it works:
   ```bash
   aws sts get-caller-identity --profile carlos-cli
   ```
   You should see the ARN `arn:aws:iam::<account-id>:user/carlos-cli`.

> 💸 **Recommended:** go to **Billing → Budgets → Create budget → "Zero spend budget"**. AWS will email you as soon as anything costs money.

> 🔐 Never put access keys in `.tf` files. Terraform will read the `carlos-cli` profile.

### Step 1: Your turn: write the code

Work in `lessons/01-first-resource/aws/`. Create **three files** (Terraform reads every `*.tf` file in the folder, so the file names are only a convention):

#### `versions.tf`: which Terraform and which providers

You need **two providers**:
- `hashicorp/aws` with a version constraint allowing any `6.x`
- `hashicorp/random`: we'll use it to make the bucket name unique

Also require Terraform `>= 1.10`.

```hcl
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # TODO: add the random provider (source "hashicorp/random", version "~> 3.6")
  }
}
```

#### `providers.tf`: configure AWS

```hcl
provider "aws" {
  region  = # TODO: eu-central-1
  profile = # TODO: your CLI profile ("carlos-cli")

  default_tags {
    tags = {
      Project   = "the-little-gamestore"
      ManagedBy = "terraform"
      Lesson    = "01"
    }
  }
}
```

#### `main.tf`: the actual resources

Build these three resources yourself. Use the Terraform Registry docs (links below) to find the arguments.

| # | Resource type | Local name | What it should do |
|---|---------------|-----------|--------------------|
| 1 | `random_pet` | `suffix` | Generate a fun 2-word suffix (e.g. `happy-panda`). Hint: `length` |
| 2 | `aws_s3_bucket` | `assets` | Bucket name `little-gamestore-assets-<suffix>` |
| 3 | `aws_s3_object` | `logo` | Upload `assets/logo.svg` into the bucket under key `brand/logo.svg`, with `content_type = "image/svg+xml"` |

Hints:
- To reference another resource's attribute: `<TYPE>.<NAME>.<ATTRIBUTE>`, e.g. `random_pet.suffix.id`
- To build a string, use interpolation: `"little-gamestore-assets-${...}"`
- To point at a local file: `"${path.module}/assets/logo.svg"`
- Bonus: make the object re-upload when the file changes, using `etag = filemd5(...)`

📚 Docs:
- https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object

### Step 2: Run the workflow

```bash
cd lessons/01-first-resource/aws
terraform init       # look at what it downloads, and at the new .terraform.lock.hcl
terraform fmt        # did it change anything?
terraform validate
terraform plan       # how many resources "to add"?
terraform apply
```

Then check your work:
```bash
terraform state list
terraform show
aws s3 ls --profile carlos-cli
aws s3 ls s3://<your-bucket-name>/brand/ --profile carlos-cli
```

### Step 3: Experiment (5 min, this is where you learn)

1. Edit `logo.svg` (change a color), then run `terraform plan`. What does Terraform want to do? With `etag` and without it?
2. Change the `Lesson` tag to `"01-test"` and run `plan`. Notice the `~` (update in-place).
3. Change `length` on `random_pet` and run `plan`. Notice `-/+` (replace). Why does the **bucket** get replaced too?

### Step 4: 🧹 Destroy

```bash
terraform destroy
```

> ❓ If destroy fails with `BucketNotEmpty`, think about why. (Hint: did Terraform create everything inside the bucket?) Look up the bucket argument `force_destroy`.

**When you're done, tell me and paste your `main.tf`, and I'll review it.** After that you get the theory and exam corner for this part.

### 🧠 Theory: what you just used

**The core workflow**

| Command | What it does |
|---|---|
| `init` | Downloads providers into `.terraform/`, writes `.terraform.lock.hcl`, sets up the backend. Run it first, and again after adding providers or modules. |
| `validate` | Checks syntax and internal consistency. Offline: it doesn't contact AWS. |
| `plan` | Refreshes state from the real world, compares it with your code, shows the difference. |
| `apply` | Runs a plan (or a saved one: `plan -out=tfplan` → `apply tfplan`). |
| `destroy` | Deletes everything tracked in state, in reverse dependency order. |
| `fmt` | Rewrites files in the standard style. `fmt -check` is for CI. |

**Plan symbols**

| Symbol | Meaning | You saw it when… |
|---|---|---|
| `+` | create | first apply |
| `~` | update in-place | logo content (etag) changed; tag changed |
| `-/+` | destroy, then create (replace) | `length` changed → `# forces replacement` |
| `-` | destroy | `terraform destroy` |
| `<=` | read (data source) | lesson 4 |

**Providers.** These are plugins that translate HCL into API calls. `required_providers` says *which* providers and versions you need (`source` = `namespace/name` on the registry). The `provider` block *configures* one, with things like region, credentials and default tags. `~> 6.0` means `>= 6.0, < 7.0`, and `~> 3.6.1` would mean `>= 3.6.1, < 3.7.0`.

**The lock file** (`.terraform.lock.hcl`) records the exact provider versions and their checksums. **Commit it** so everyone gets the same versions. Run `terraform init -upgrade` to move to newer versions that the constraints allow.

**State** (`terraform.tfstate`) is Terraform's memory: it maps `aws_s3_bucket.assets` to the real bucket `little-gamestore-assets-coherent-garfish`. Without it, Terraform doesn't know what it owns. It's stored in plain text and can contain secrets, so **never commit it**. Lesson 6 moves it to a remote backend.

**Dependencies.** Referencing another resource (`aws_s3_bucket.assets.id`) creates an **implicit dependency**: Terraform builds a graph, creates things in dependency order, runs independent ones in parallel, and destroys in reverse. `depends_on` (explicit) is only for hidden dependencies that Terraform can't see in your code.

**`path.module`** is the folder of the current module. Use it for every local file path, so the code works no matter where `terraform` is run from.

### 📝 Exam corner

1. You add a new provider to `required_providers`. What must you run before `plan` works?
2. Which command checks configuration syntax **without** accessing any remote API?
3. A teammate's `apply` installed AWS provider 6.20 while you got 6.14. Which file prevents this, and should it be committed?
4. What does the version constraint `~> 1.4.0` allow?
5. True or false: `terraform destroy` requires the state file to know what to delete.
6. In a plan you see `-/+ resource "aws_s3_bucket" "assets"` with `# forces replacement` next to `bucket`. What will happen to the files inside the bucket?

<details><summary>Answers</summary>

1. `terraform init` (it downloads the new provider).
2. `terraform validate`.
3. `.terraform.lock.hcl`, and yes, commit it.
4. `>= 1.4.0` and `< 1.5.0` (only the rightmost number may increase).
5. True. Terraform only manages what is recorded in state.
6. The old bucket is deleted and a new empty one is created. Data not managed by Terraform is lost (and the delete fails if the bucket isn't empty, unless `force_destroy = true`).

</details>

### 🧪 Challenge (optional)

Upload a second file, `assets/welcome.txt` with the text "Welcome to The Little Gamestore!", under the key `brand/welcome.txt`. Then make the `random_pet` use `separator = "_"`, run `plan` and then `apply`. Why does `plan` look fine, but `apply` fails? (Hints: S3 bucket naming rules, and *when* is the pet name known?) Set the separator back afterwards.

---

## Part 2: STACKIT

*(Next session.)*
