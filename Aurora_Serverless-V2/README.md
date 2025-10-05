# Aurora Serverless V2 Terraform構成

## 概要

このTerraform構成は、AWS Aurora Serverless V2クラスターを構築します。VPCレイヤから構築し、最小ACU 0、最大ACU 4の設定により、利用がない時はコスト0、負荷に応じて自動スケーリングする構成を実現します。

### 主な特徴

- **コスト最適化**: 最小ACU 0により、利用がない時のコンピューティングコストが0円
- **自動スケーリング**: 負荷に応じて0～4 ACUの範囲で自動調整
- **常時起動**: いつでもアクセス可能な開発環境
- **高可用性**: 複数AZにまたがるプライベートサブネット構成
- **セキュア**: パブリックアクセス無効、VPC内からのみアクセス可能

## Aurora Serverless V2の特徴

### 最小ACU 0のメリット

- **コスト削減**: 利用がない時間帯（夜間・週末等）のコンピューティングコストが0円
- **即座に利用可能**: 常時起動のため、スケジュール起動・停止の管理が不要
- **自動スケーリング**: 初回アクセス時に数秒でスケールアップ

### スケーリング動作

```
利用なし → ACU 0 (コスト0円)
    ↓
初回アクセス → 数秒でACU 1以上にスケールアップ
    ↓
負荷増加 → 最大ACU 4まで自動スケールアップ
    ↓
負荷減少 → 自動的にスケールダウン → ACU 0に戻る
```

### ACU（Aurora Capacity Units）とは

1 ACU = 約2GBメモリ + 対応するCPU・ネットワーク性能

- **ACU 0**: コンピューティングリソースなし（ストレージのみ課金）
- **ACU 1**: 約2GBメモリ
- **ACU 4**: 約8GBメモリ（db.m5d.large相当）

## 前提条件

### 必要なツール

- **Terraform**: バージョン 1.0以上
  ```bash
  terraform version
  ```

- **AWS CLI**: バージョン 2.x以上
  ```bash
  aws --version
  ```

### AWS認証情報

以下のいずれかの方法でAWS認証情報を設定してください：

1. **AWS CLIの設定**（推奨）
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

### 必要なIAM権限

以下のAWSサービスに対する権限が必要です：

- Amazon VPC（VPC、サブネット、セキュリティグループの作成・管理）
- Amazon RDS（Auroraクラスター、インスタンスの作成・管理）
- Amazon EC2（ネットワークリソースの管理）

## 使用方法

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd Terraform/Aurora_Serverless-V2
```

### 2. 変数ファイルの作成

サンプルファイルをコピーして、環境に合わせて編集します：

```bash
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`を編集して、以下の値を必ず変更してください：

```hcl
# 必須: プロジェクト名を設定
project_name = "your-project-name"

# 必須: クラスター識別子を設定（一意である必要があります）
cluster_identifier = "your-cluster-name"

# 必須: データベース名を設定
database_name = "your_database_name"

# 重要: マスターパスワードを変更してください！
master_password = "YourSecurePassword123!"
```

### 3. Terraformの初期化

```bash
terraform init
```

このコマンドは以下を実行します：
- 必要なプロバイダー（AWS）のダウンロード
- バックエンドの初期化
- モジュールのダウンロード

### 4. 実行プランの確認

```bash
terraform plan
```

作成されるリソースを確認します：
- VPC × 1
- プライベートサブネット × 2
- セキュリティグループ × 1
- DB Subnet Group × 1
- Auroraクラスター × 1
- Auroraインスタンス × 1

### 5. リソースの作成

```bash
terraform apply
```

確認プロンプトで`yes`と入力すると、リソースが作成されます。
作成には約10～15分かかります。

### 6. 出力値の確認

```bash
terraform output
```

以下の情報が表示されます：
- VPC ID
- サブネットID
- Auroraクラスターエンドポイント（書き込み用）
- Auroraリーダーエンドポイント（読み取り用）
- データベース名
- ポート番号

### 7. データベースへの接続

#### MySQLの場合

```bash
# エンドポイントを取得
ENDPOINT=$(terraform output -raw cluster_endpoint)

# 接続
mysql -h $ENDPOINT -u admin -p myappdb
```

#### PostgreSQLの場合

```bash
# エンドポイントを取得
ENDPOINT=$(terraform output -raw cluster_endpoint)

# 接続
psql -h $ENDPOINT -U admin -d myappdb
```

### 8. リソースの削除

```bash
terraform destroy
```

確認プロンプトで`yes`と入力すると、すべてのリソースが削除されます。

## 変数の説明とカスタマイズ方法

### プロジェクト設定

| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|--------------|------|
| `project_name` | プロジェクト名（リソース名のプレフィックス） | - | ✓ |
| `environment` | 環境名 | `"development"` | |
| `aws_region` | AWSリージョン | `"ap-northeast-1"` | |

### VPC設定

| 変数名 | 説明 | デフォルト値 |
|--------|------|--------------|
| `vpc_cidr` | VPCのCIDRブロック | `"10.0.0.0/16"` |
| `private_subnet_cidrs` | プライベートサブネットのCIDRリスト | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `availability_zones` | 使用するAZ | `["ap-northeast-1a", "ap-northeast-1c"]` |
| `allowed_cidr_blocks` | アクセスを許可するCIDR | `["10.0.0.0/16"]` |
| `database_port` | データベースポート | `3306` (MySQL) / `5432` (PostgreSQL) |

### Aurora設定

| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|--------------|------|
| `cluster_identifier` | クラスター識別子 | - | ✓ |
| `engine` | エンジン | `"aurora-mysql"` | |
| `engine_version` | エンジンバージョン | `"8.0.mysql_aurora.3.04.0"` | |
| `database_name` | 初期データベース名 | - | ✓ |
| `master_username` | マスターユーザー名 | - | ✓ |
| `master_password` | マスターパスワード | - | ✓ |

### スケーリング設定

| 変数名 | 説明 | デフォルト値 | 推奨値 |
|--------|------|--------------|--------|
| `min_capacity` | 最小ACU | `0` | 開発: 0、本番: 0.5-1 |
| `max_capacity` | 最大ACU | `4` | 開発: 2-4、本番: 8-16 |

### バックアップ設定

| 変数名 | 説明 | デフォルト値 | 推奨値 |
|--------|------|--------------|--------|
| `backup_retention_period` | バックアップ保持期間（日） | `1` | 開発: 1、本番: 7-35 |
| `preferred_backup_window` | バックアップウィンドウ（UTC） | `"17:00-18:00"` | |
| `preferred_maintenance_window` | メンテナンスウィンドウ（UTC） | `"sun:18:00-sun:19:00"` | |

### セキュリティ設定

| 変数名 | 説明 | デフォルト値 | 推奨値 |
|--------|------|--------------|--------|
| `deletion_protection` | 削除保護 | `false` | 開発: false、本番: true |
| `skip_final_snapshot` | 最終スナップショットのスキップ | `true` | 開発: true、本番: false |

### カスタマイズ例

#### PostgreSQLを使用する場合

```hcl
engine         = "aurora-postgresql"
engine_version = "15.2"
database_port  = 5432
```

#### 本番環境向けの設定

```hcl
environment             = "production"
min_capacity            = 1
max_capacity            = 16
backup_retention_period = 7
deletion_protection     = true
skip_final_snapshot     = false
instance_count          = 2
```

#### 環境変数でパスワードを設定

```bash
export TF_VAR_master_password="YourSecurePassword123!"
terraform apply
```

## 注意事項

### 初回接続の遅延

最小ACU 0の場合、初回アクセス時にACUがスケールアップするまで**数秒の遅延**が発生します。

**対策:**
- アプリケーション側で接続タイムアウトを30秒以上に設定
- リトライロジックを実装
- 本番環境では最小ACU 0.5～1を推奨

### セキュリティ

#### パスワード管理

- `terraform.tfvars`は`.gitignore`に追加済み（コミットしないこと）
- 本番環境では環境変数またはAWS Secrets Managerを使用
- パスワードは8文字以上、英数字と記号を含むこと

#### ネットワークセキュリティ

- Auroraクラスターはプライベートサブネットに配置
- パブリックアクセスは無効化
- VPC内からのみアクセス可能
- 必要に応じて`allowed_cidr_blocks`を調整

#### IAM認証（オプション）

より安全な認証方法として、IAM認証の使用を検討してください：

```hcl
# modules/aurora/main.tfに追加
iam_database_authentication_enabled = true
```

### エンジンバージョン

Aurora Serverless V2は特定のバージョンのみサポートしています：

- **MySQL**: 8.0.mysql_aurora.3.04.0以降
- **PostgreSQL**: 15.2以降

最新のサポートバージョンは[AWS公式ドキュメント](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)で確認してください。

### 削除保護

開発環境では削除保護を無効化していますが、誤削除を防ぐため、重要なデータがある場合は有効化してください：

```hcl
deletion_protection = true
```

削除保護が有効な場合、`terraform destroy`の前に無効化が必要です：

```bash
aws rds modify-db-cluster \
  --db-cluster-identifier your-cluster-name \
  --no-deletion-protection \
  --apply-immediately
```

## コスト見積もり

### 東京リージョン（ap-northeast-1）の料金例

#### 開発環境（最小ACU 0、最大ACU 4）

**シナリオ1: 平日のみ稼働（月～金 9:00-18:00）**

- 稼働時間: 約180時間/月
- 平均ACU: 2
- コンピューティング: $0.15/ACU/時間 × 2 ACU × 180時間 = **$54.00**
- ストレージ: $0.12/GB/月 × 100GB = **$12.00**
- **月額合計: 約$66.00（約9,900円）**

**シナリオ2: 24時間稼働（負荷は低め）**

- 稼働時間: 720時間/月
- 平均ACU: 1（夜間・週末はACU 0）
- 実質稼働: 300時間/月
- コンピューティング: $0.15/ACU/時間 × 1 ACU × 300時間 = **$45.00**
- ストレージ: $0.12/GB/月 × 100GB = **$12.00**
- **月額合計: 約$57.00（約8,550円）**

#### 本番環境（最小ACU 1、最大ACU 16）

**シナリオ: 24時間稼働（平均ACU 4）**

- 稼働時間: 720時間/月
- 平均ACU: 4
- コンピューティング: $0.15/ACU/時間 × 4 ACU × 720時間 = **$432.00**
- ストレージ: $0.12/GB/月 × 500GB = **$60.00**
- バックアップ: $0.021/GB/月 × 500GB = **$10.50**
- **月額合計: 約$502.50（約75,375円）**

### コスト削減のヒント

1. **最小ACU 0を活用**: 利用がない時間帯のコストを0に
2. **最大ACUを調整**: 実際の負荷に応じて2～4に設定
3. **バックアップ保持期間**: 開発環境は1日で十分
4. **不要なスナップショット削除**: 定期的にクリーンアップ
5. **ストレージ最適化**: 不要なデータを削除

### コスト監視

AWS Cost Explorerで以下を定期的に確認：

```bash
# 月間コストの確認
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://filter.json
```

## トラブルシューティング

### 接続できない

#### 症状
データベースに接続できない、タイムアウトエラーが発生する

#### 確認事項

1. **エンドポイントの確認**
   ```bash
   terraform output cluster_endpoint
   ```

2. **セキュリティグループの確認**
   ```bash
   aws ec2 describe-security-groups \
     --filters "Name=tag:Name,Values=*aurora*"
   ```

3. **接続元のネットワーク**
   - VPC内のEC2インスタンスから接続していますか？
   - `allowed_cidr_blocks`に接続元が含まれていますか？

4. **初回接続の遅延**
   - 最小ACU 0の場合、初回接続に数秒かかります
   - 接続タイムアウトを30秒以上に設定してください

#### 解決方法

```bash
# セキュリティグループルールの確認
aws ec2 describe-security-group-rules \
  --filters "Name=group-id,Values=<security-group-id>"

# クラスターの状態確認
aws rds describe-db-clusters \
  --db-cluster-identifier <cluster-identifier>
```

### Terraform apply が失敗する

#### 症状
`terraform apply`実行時にエラーが発生する

#### よくあるエラー

**1. クラスター識別子の重複**
```
Error: DBClusterAlreadyExistsFault
```

**解決方法**: `cluster_identifier`を変更してください

**2. IAM権限不足**
```
Error: UnauthorizedOperation
```

**解決方法**: 必要なIAM権限を付与してください

**3. エンジンバージョンが無効**
```
Error: InvalidParameterValue: Invalid engine version
```

**解決方法**: サポートされているバージョンを指定してください
```bash
# 利用可能なバージョンの確認
aws rds describe-db-engine-versions \
  --engine aurora-mysql \
  --query 'DBEngineVersions[?SupportsServerlessV2==`true`].EngineVersion'
```

### ACUがスケールアップしない

#### 症状
負荷をかけてもACUが増えない

#### 確認事項

1. **スケーリング設定の確認**
   ```bash
   aws rds describe-db-clusters \
     --db-cluster-identifier <cluster-identifier> \
     --query 'DBClusters[0].ServerlessV2ScalingConfiguration'
   ```

2. **CloudWatch メトリクスの確認**
   ```bash
   aws cloudwatch get-metric-statistics \
     --namespace AWS/RDS \
     --metric-name ServerlessDatabaseCapacity \
     --dimensions Name=DBClusterIdentifier,Value=<cluster-identifier> \
     --start-time 2024-01-01T00:00:00Z \
     --end-time 2024-01-01T23:59:59Z \
     --period 300 \
     --statistics Average
   ```

3. **接続数の確認**
   ```bash
   # データベースに接続して確認
   SHOW PROCESSLIST;  # MySQL
   SELECT * FROM pg_stat_activity;  # PostgreSQL
   ```

### terraform destroy が失敗する

#### 症状
リソースの削除に失敗する

#### よくある原因

**1. 削除保護が有効**
```
Error: Cannot delete protected cluster
```

**解決方法**:
```bash
aws rds modify-db-cluster \
  --db-cluster-identifier <cluster-identifier> \
  --no-deletion-protection \
  --apply-immediately

terraform destroy
```

**2. 最終スナップショットが必要**
```
Error: FinalSnapshotIdentifierRequired
```

**解決方法**: `skip_final_snapshot = true`を設定するか、スナップショット識別子を指定

### パフォーマンスが遅い

#### 症状
クエリの実行が遅い、レスポンスタイムが長い

#### 確認事項

1. **現在のACUを確認**
   ```bash
   aws cloudwatch get-metric-statistics \
     --namespace AWS/RDS \
     --metric-name ServerlessDatabaseCapacity \
     --dimensions Name=DBClusterIdentifier,Value=<cluster-identifier> \
     --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
     --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
     --period 60 \
     --statistics Average
   ```

2. **最大ACUに達していないか確認**
   - 最大ACUに達している場合は、`max_capacity`を増やす

3. **クエリの最適化**
   - Performance Insightsを有効化
   - スロークエリログを確認
   - インデックスを追加

#### 解決方法

```hcl
# 最大ACUを増やす
max_capacity = 8  # または 16
```

### コストが予想より高い

#### 症状
月額コストが見積もりより高い

#### 確認事項

1. **ACU使用率の確認**
   ```bash
   # 過去1週間の平均ACU
   aws cloudwatch get-metric-statistics \
     --namespace AWS/RDS \
     --metric-name ServerlessDatabaseCapacity \
     --dimensions Name=DBClusterIdentifier,Value=<cluster-identifier> \
     --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
     --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
     --period 3600 \
     --statistics Average
   ```

2. **ストレージ使用量の確認**
   ```bash
   aws rds describe-db-clusters \
     --db-cluster-identifier <cluster-identifier> \
     --query 'DBClusters[0].AllocatedStorage'
   ```

3. **バックアップストレージの確認**
   ```bash
   aws rds describe-db-cluster-snapshots \
     --db-cluster-identifier <cluster-identifier>
   ```

#### 解決方法

- 最大ACUを下げる（4 → 2）
- バックアップ保持期間を短縮（7日 → 1日）
- 不要なスナップショットを削除
- 不要なデータを削除してストレージを削減

## 参考リンク

- [Aurora Serverless V2 公式ドキュメント](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
- [Aurora Serverless V2 料金](https://aws.amazon.com/rds/aurora/pricing/)
- [Terraform AWS Provider ドキュメント](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Aurora Serverless V2 ベストプラクティス](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.best-practices.html)

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## サポート

問題が発生した場合は、以下を確認してください：

1. このREADMEのトラブルシューティングセクション
2. AWS公式ドキュメント
3. Terraformの公式ドキュメント

それでも解決しない場合は、Issueを作成してください。
