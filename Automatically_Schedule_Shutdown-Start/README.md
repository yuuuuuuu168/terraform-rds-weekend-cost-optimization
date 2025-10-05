# RDS自動停止/起動スケジューラー

開発用RDSインスタンスを自動的に停止・起動することでコストを最適化するTerraform構成です。EventBridge Schedulerを使用して、平日は稼働、土日は停止することで、最大約60%のコスト削減を実現します。

## 概要

このプロジェクトは以下のリソースを作成します：

- **VPC**: プライベートサブネット2つを含む独立したネットワーク環境
- **RDS**: MySQL/PostgreSQLデータベースインスタンス（シングルAZ構成）
- **EventBridge Scheduler**: 自動停止/起動スケジュール
- **IAM Role**: Scheduler実行用の権限

### アーキテクチャ図

```
┌─────────────────────────────────────────────────────────┐
│ VPC (10.0.0.0/16)                                       │
│                                                         │
│  ┌──────────────────┐    ┌──────────────────┐         │
│  │ Private Subnet   │    │ Private Subnet   │         │
│  │ 10.0.1.0/24      │    │ 10.0.2.0/24      │         │
│  │ (ap-northeast-1a)│    │ (ap-northeast-1c)│         │
│  └────────┬─────────┘    └────────┬─────────┘         │
│           │                       │                    │
│           └───────┬───────────────┘                    │
│                   │                                    │
│           ┌───────▼────────┐                           │
│           │ DB Subnet Group│                           │
│           └───────┬────────┘                           │
│                   │                                    │
│           ┌───────▼────────┐                           │
│           │  RDS Instance  │                           │
│           │  (MySQL/PG)    │                           │
│           └────────────────┘                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ EventBridge Scheduler                                   │
│                                                         │
│  ┌──────────────────┐    ┌──────────────────┐         │
│  │ Stop Schedule    │    │ Start Schedule   │         │
│  │ 土曜 00:00 JST   │    │ 月曜 00:00 JST   │         │
│  └────────┬─────────┘    └────────┬─────────┘         │
│           │                       │                    │
│           └───────┬───────────────┘                    │
│                   │                                    │
│           ┌───────▼────────┐                           │
│           │   IAM Role     │                           │
│           │ (RDS権限)      │                           │
│           └────────────────┘                           │
└─────────────────────────────────────────────────────────┘
```

## 前提条件

### 必要なツール

- **Terraform**: v1.0以上
  ```bash
  terraform version
  ```

- **AWS CLI**: v2.0以上
  ```bash
  aws --version
  ```

### AWS認証情報

以下のいずれかの方法でAWS認証情報を設定してください：

1. **AWS CLIの設定**
   ```bash
   aws configure
   ```

2. **環境変数**
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="ap-northeast-1"
   ```

3. **IAMロール**（EC2インスタンス上で実行する場合）

### 必要な権限

Terraformを実行するIAMユーザー/ロールには以下の権限が必要です：

- VPC、サブネット、セキュリティグループの作成・管理
- RDSインスタンスの作成・管理
- EventBridge Schedulerの作成・管理
- IAMロール・ポリシーの作成・管理

## 使用方法

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd Terraform/Automatically_Schedule_Shutdown-Start
```

### 2. 変数ファイルの作成

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. 変数の編集

`terraform.tfvars`ファイルを編集して、環境に合わせた値を設定します：

```hcl
# 必須項目
project_name = "myapp"
rds_identifier = "myapp-dev-db"
rds_db_name = "myappdb"
rds_username = "admin"
rds_password = "YourSecurePassword123!"  # 必ず変更してください

# オプション項目（デフォルト値で問題なければ変更不要）
rds_instance_class = "db.t3.micro"
rds_allocated_storage = 20
```

### 4. Terraformの初期化

```bash
terraform init
```

### 5. プランの確認

```bash
terraform plan
```

作成されるリソースを確認します。問題がなければ次のステップへ進みます。

### 6. リソースの作成

```bash
terraform apply
```

`yes`と入力して実行を確定します。作成には5-10分程度かかります。

### 7. 出力値の確認

```bash
terraform output
```

RDSエンドポイントやスケジュールARNなどの重要な情報が表示されます。

## 変数の説明とカスタマイズ

### プロジェクト設定

| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `project_name` | プロジェクト名（リソース名のプレフィックス） | - | ✓ |
| `environment` | 環境名 | `development` | |
| `aws_region` | AWSリージョン | `ap-northeast-1` | |

### VPC設定

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `vpc_cidr` | VPCのCIDRブロック | `10.0.0.0/16` |
| `private_subnet_cidrs` | プライベートサブネットのCIDRリスト | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `availability_zones` | 使用するAZ | `["ap-northeast-1a", "ap-northeast-1c"]` |
| `allowed_cidr_blocks` | RDSへのアクセスを許可するCIDR | `["10.0.0.0/16"]` |

### RDS設定

| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `rds_identifier` | RDSインスタンスの識別子 | - | ✓ |
| `rds_engine` | データベースエンジン（mysql/postgres） | `mysql` | |
| `rds_engine_version` | エンジンバージョン | `8.0.35` | |
| `rds_instance_class` | インスタンスクラス | `db.t3.micro` | |
| `rds_allocated_storage` | ストレージサイズ（GB） | `20` | |
| `rds_storage_type` | ストレージタイプ | `gp3` | |
| `rds_db_name` | 初期データベース名 | - | ✓ |
| `rds_username` | マスターユーザー名 | - | ✓ |
| `rds_password` | マスターパスワード | - | ✓ |
| `rds_backup_retention_period` | バックアップ保持期間（日） | `1` | |
| `rds_multi_az` | マルチAZ構成 | `false` | |
| `rds_publicly_accessible` | パブリックアクセス | `false` | |
| `rds_deletion_protection` | 削除保護 | `false` | |

### スケジュール設定

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `stop_schedule` | 停止スケジュール（cron形式、UTC） | `cron(0 15 ? * FRI *)` |
| `start_schedule` | 起動スケジュール（cron形式、UTC） | `cron(0 15 ? * SUN *)` |
| `timezone` | タイムゾーン | `Asia/Tokyo` |

## スケジュールの調整方法

### デフォルトのスケジュール

- **停止**: 土曜日 00:00 JST（金曜日 15:00 UTC）
- **起動**: 月曜日 00:00 JST（日曜日 15:00 UTC）

### スケジュールのカスタマイズ

EventBridge Schedulerのcron形式を使用します：

```
cron(分 時 日 月 曜日 年)
```

#### 例1: 金曜日の20:00 JSTに停止、月曜日の07:00 JSTに起動

```hcl
stop_schedule = "cron(0 11 ? * FRI *)"   # JST 20:00 = UTC 11:00
start_schedule = "cron(0 22 ? * SUN *)"  # JST 月曜 07:00 = UTC 日曜 22:00
```

#### 例2: 毎日22:00 JSTに停止、毎日08:00 JSTに起動

```hcl
stop_schedule = "cron(0 13 ? * * *)"   # JST 22:00 = UTC 13:00
start_schedule = "cron(0 23 ? * * *)"  # JST 08:00 = UTC 前日 23:00
```

### スケジュールの一時停止

長期休暇などでスケジュールを一時停止する場合：

```bash
# 停止スケジュールを無効化
aws scheduler update-schedule \
  --name <project-name>-<environment>-stop-rds \
  --state DISABLED

# 起動スケジュールを無効化
aws scheduler update-schedule \
  --name <project-name>-<environment>-start-rds \
  --state DISABLED
```

再開する場合は`--state ENABLED`を指定します。

## 注意事項

### 1. RDSの7日間自動起動制限

**重要**: RDSは停止後7日間で自動的に起動されます。

- 長期休暇（GW、お盆、年末年始）では、7日以内に一度起動されます
- 長期間停止したい場合は、スナップショットを取得してインスタンスを削除することを検討してください

### 2. セキュリティ

#### パスワード管理

- `terraform.tfvars`にパスワードを平文で保存しないでください
- 本番環境では以下の方法を推奨：

**環境変数を使用**
```bash
export TF_VAR_rds_password="YourSecurePassword123!"
terraform apply
```

**AWS Secrets Managerを使用**（推奨）
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "myapp/db/password"
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

#### ネットワークセキュリティ

- RDSはプライベートサブネットに配置され、パブリックアクセスは無効
- セキュリティグループでVPC内からのアクセスのみ許可
- 本番環境では`rds_deletion_protection = true`を設定してください

### 3. バックアップ

- 自動バックアップは毎日実行されます（デフォルト: JST 02:00-03:00）
- 開発環境では保持期間1日、本番環境では7日以上を推奨
- RDS停止中もバックアップは実行されます

### 4. コスト

- 停止中はストレージ費用とバックアップ費用のみが発生
- インスタンス費用は停止中は課金されません
- 詳細は「コスト見積もり」セクションを参照

## コスト見積もり

### 前提条件

- リージョン: ap-northeast-1（東京）
- インスタンスクラス: db.t3.micro
- ストレージ: 20GB gp3
- バックアップ: 20GB（1日保持）
- 稼働時間: 平日のみ（週5日）

### 月間コスト（概算）

#### 24時間365日稼働の場合

| 項目 | 単価 | 使用量 | 月額 |
|------|------|--------|------|
| インスタンス（db.t3.micro） | $0.018/時間 | 730時間 | $13.14 |
| ストレージ（gp3） | $0.138/GB | 20GB | $2.76 |
| バックアップストレージ | $0.095/GB | 20GB | $1.90 |
| **合計** | | | **$17.80** |

#### 平日のみ稼働の場合（本構成）

| 項目 | 単価 | 使用量 | 月額 |
|------|------|--------|------|
| インスタンス（db.t3.micro） | $0.018/時間 | 約480時間 | $8.64 |
| ストレージ（gp3） | $0.138/GB | 20GB | $2.76 |
| バックアップストレージ | $0.095/GB | 20GB | $1.90 |
| EventBridge Scheduler | $1.00/100万実行 | 8実行 | $0.00 |
| **合計** | | | **$13.30** |

**削減額**: 約$4.50/月（約25%削減）

### コスト最適化のヒント

1. **インスタンスクラスの最適化**
   - 負荷が低い場合はdb.t3.microで十分
   - 必要に応じてdb.t3.small（$0.036/時間）にスケールアップ

2. **ストレージの最適化**
   - 必要最小限のサイズから開始
   - 自動スケーリングは無効化（開発環境）

3. **バックアップの最適化**
   - 開発環境では保持期間1日で十分
   - 本番環境では7日以上を推奨

4. **スケジュールの最適化**
   - 実際の業務時間に合わせて調整
   - 祝日は手動で停止

## トラブルシューティング

### Terraform実行時のエラー

#### エラー: "Error creating DB Instance: DBInstanceAlreadyExists"

**原因**: 同じ識別子のRDSインスタンスが既に存在

**解決方法**:
```bash
# 既存インスタンスを確認
aws rds describe-db-instances --db-instance-identifier <your-identifier>

# 削除する場合
aws rds delete-db-instance \
  --db-instance-identifier <your-identifier> \
  --skip-final-snapshot
```

#### エラー: "Error creating VPC: VpcLimitExceeded"

**原因**: VPCの上限（デフォルト5個）に達している

**解決方法**:
```bash
# 既存VPCを確認
aws ec2 describe-vpcs

# 不要なVPCを削除するか、AWS Supportに上限緩和を依頼
```

### RDS接続エラー

#### エラー: "Could not connect to database"

**確認事項**:

1. **RDSが起動しているか確認**
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier <your-identifier> \
     --query 'DBInstances[0].DBInstanceStatus'
   ```

2. **エンドポイントを確認**
   ```bash
   terraform output db_instance_endpoint
   ```

3. **セキュリティグループを確認**
   ```bash
   aws ec2 describe-security-groups \
     --group-ids <security-group-id>
   ```

4. **接続元がVPC内にあるか確認**
   - RDSはプライベートサブネットにあり、VPC外からは接続不可
   - 接続にはVPN、Direct Connect、またはEC2踏み台サーバーが必要

### スケジューラーが動作しない

#### スケジュールが実行されない

**確認事項**:

1. **スケジュールの状態を確認**
   ```bash
   aws scheduler list-schedules
   ```

2. **スケジュールの詳細を確認**
   ```bash
   aws scheduler get-schedule \
     --name <project-name>-<environment>-stop-rds
   ```

3. **IAMロールの権限を確認**
   ```bash
   aws iam get-role-policy \
     --role-name <project-name>-<environment>-scheduler-role \
     --policy-name rds-scheduler-policy
   ```

4. **CloudWatch Logsを確認**
   - EventBridge Schedulerの実行ログを確認
   - エラーメッセージがないか確認

#### タイムゾーンが正しくない

**確認事項**:
- スケジュールはUTCで指定する必要があります
- JST = UTC + 9時間
- 例: JST 00:00 = UTC 前日 15:00

### リソースの削除エラー

#### エラー: "Error deleting DB Instance: InvalidDBInstanceState"

**原因**: RDSが削除保護されている、または削除中

**解決方法**:
```bash
# 削除保護を無効化
aws rds modify-db-instance \
  --db-instance-identifier <your-identifier> \
  --no-deletion-protection \
  --apply-immediately

# 再度削除を試行
terraform destroy
```

#### エラー: "DependencyViolation: The vpc has dependencies"

**原因**: VPC内にリソースが残っている

**解決方法**:
```bash
# VPC内のリソースを確認
aws ec2 describe-network-interfaces \
  --filters "Name=vpc-id,Values=<vpc-id>"

# 手動で削除するか、terraform destroyを再実行
```

## メンテナンス

### 定期的な確認事項

- [ ] バックアップが正常に実行されているか（週次）
- [ ] ストレージ使用量の確認（月次）
- [ ] エンジンバージョンのアップデート確認（四半期）
- [ ] セキュリティパッチの適用（随時）

### バージョンアップ

#### エンジンバージョンのアップデート

```hcl
# terraform.tfvarsを編集
rds_engine_version = "8.0.36"  # 新しいバージョン
```

```bash
terraform plan
terraform apply
```

#### Terraformバージョンのアップデート

```bash
# 現在のバージョンを確認
terraform version

# 最新版をインストール
# https://www.terraform.io/downloads

# プロバイダーのアップデート
terraform init -upgrade
```

## リソースの削除

### すべてのリソースを削除

```bash
terraform destroy
```

### 削除保護が有効な場合

```bash
# 削除保護を無効化
aws rds modify-db-instance \
  --db-instance-identifier <your-identifier> \
  --no-deletion-protection \
  --apply-immediately

# 削除を実行
terraform destroy
```

### 最終スナップショットを取得して削除

```hcl
# terraform.tfvarsを編集
rds_skip_final_snapshot = false
```

```bash
terraform destroy
```

## 参考リンク

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon RDS User Guide](https://docs.aws.amazon.com/rds/)
- [EventBridge Scheduler User Guide](https://docs.aws.amazon.com/scheduler/)
- [AWS Pricing Calculator](https://calculator.aws/)

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## サポート

問題が発生した場合は、GitHubのIssueを作成してください。
