# RDS 休日コスト最適化 Terraform構成集

## 概要

このリポジトリは、開発用RDSの休日コスト最適化を実現するための2つのアプローチをTerraformで実装したものです。

開発環境では平日は活発に利用されるものの、土日祝日は全く利用されないケースが多くあります。このような場合、適切な方法でコストを最適化することで、年間で数万円～数十万円のコスト削減が可能です。

## 背景と課題

### 開発用RDSの典型的な利用パターン

- 平日（月～金）: 開発者が活発に利用、読み書きが頻繁に発生
- 休日（土日祝）: 利用がほぼゼロ、DBは起動しているだけで課金

### 解決したい課題

1. 休日の無駄なコスト: 使っていないのにインスタンス料金が発生
2. 運用の手間: 手動での停止・起動は忘れがち
3. セキュリティ: 休日に勝手に使われないようにしたい

## 2つのアプローチ

このリポジトリでは、以下の2つのアプローチを提供しています。

###  [パターン1: RDS 自動停止・起動スケジュール](./Automatically_Schedule_Shutdown-Start/)

EventBridge Schedulerを使用して、RDSを自動的に停止・起動

#### 特徴
-  シンプルで確実: 使わない時間帯は完全に停止
-  コスト削減効果が高い: 停止中はストレージ費用のみ
-  既存RDSをそのまま利用: 移行作業不要
-  起動に時間がかかる: 数分程度の起動時間が必要
-  7日間制限: 停止後7日で自動起動される

#### 推奨ケース
- 既存のRDSを使用している
- 平日のみ利用、土日は完全に不要
- 起動時間の遅延が許容できる
- シンプルな構成を維持したい

#### コスト例（db.m5d.large、200GB、東京リージョン）
- 月額: 約$181（約27,000円）
- 24時間稼働との比較: 約25%削減

###  [パターン2: Aurora Serverless V2](./Aurora_Serverless-V2/)

最小ACU 0に設定し、利用がない時は自動的にコスト0に

#### 特徴
-  常時利用可能: いつでもアクセス可能、起動待ち不要
-  自動スケーリング: 負荷に応じて自動調整
-  初回アクセスは数秒: スケールアップが高速
-  ACU単価が高い: 平均ACUが高いとコスト増
-  移行が必要: RDSからの移行作業が発生

#### 推奨ケース
- 休日も時々アクセスする可能性がある
- 起動待ち時間をゼロにしたい
- 負荷の変動が大きい（スパイクがある）
- 新規プロジェクトで構成を選べる

#### コスト例（最大4ACU、200GB、東京リージョン）
- 平均2ACU稼働: 約$182（約27,000円）- パターン1とほぼ同等
- 平均4ACU稼働: 約$341（約51,000円）- パターン1の約2倍

## コスト比較表

### 前提条件
- インスタンスクラス: db.m5d.large（RDS）/ 最大4ACU（Aurora）
- ストレージ: 200GB
- 稼働時間: 平日22日×24h=528h、休日8日×24h=192h
- リージョン: 東京（ap-northeast-1）
- 為替レート: 1ドル=150円

### 月額コスト比較

| パターン | 平日コスト | 休日コスト | 月額合計 | 円換算 | パターン1との差額 |
|:---------|----------:|----------:|---------:|-------:|:-----------------|
| 24時間稼働（参考） | $181.25 | $60.42 | $241.67 | ¥36,250 | +$60.42 (+33%) |
| パターン1<br>RDS 自動停止・起動 | $153.65 | $0.00 | $181.25 | ¥27,188 | 基準 |
| パターン2<br>Aurora Serverless V2<br>（平均2ACU） | $158.40 | $0.00 | $182.40 | ¥27,360 | +$1.15 (+0.6%) |
| パターン2<br>Aurora Serverless V2<br>（平均4ACU） | $316.80 | $0.00 | $340.80 | ¥51,120 | +$159.55 (+88%) |

### 年間コスト削減効果

| パターン | 年間コスト | 24時間稼働との差額 | 削減率 |
|:---------|----------:|------------------:|-------:|
| 24時間稼働（参考） | ¥435,000 | - | - |
| パターン1: RDS自動停止 | ¥326,256 | -¥108,744 | 25%削減 |
| パターン2: Aurora（2ACU） | ¥328,320 | -¥106,680 | 25%削減 |
| パターン2: Aurora（4ACU） | ¥613,440 | +¥178,440 | 41%増加 |

## 選択ガイド

### パターン1（RDS自動停止）を選ぶべきケース

 以下に当てはまる場合はパターン1がおすすめ

- 既存のRDSを使用している
- 平日のみ利用、土日は完全に不要
- 朝の起動時間（数分）が許容できる
- シンプルな構成を維持したい
- 確実にコストを削減したい

### パターン2（Aurora Serverless V2）を選ぶべきケース

 以下に当てはまる場合はパターン2がおすすめ

- 休日も時々アクセスする可能性がある
- 起動待ち時間をゼロにしたい
- 負荷の変動が大きい（自動スケーリングが必要）
- 新規プロジェクトで構成を選べる
- 平均ACUを2以下に抑えられる見込みがある

## 各パターンの詳細

### パターン1: RDS 自動停止・起動スケジュール

詳細は [Automatically_Schedule_Shutdown-Start/README.md](./Automatically_Schedule_Shutdown-Start/README.md) を参照してください。

主な構成要素:
- VPC（プライベートサブネット×2）
- RDS（MySQL/PostgreSQL）
- EventBridge Scheduler（停止・起動スケジュール）
- IAM Role（Scheduler実行権限）

デフォルトスケジュール:
- 停止: 土曜日 00:00 JST
- 起動: 月曜日 00:00 JST

### パターン2: Aurora Serverless V2

詳細は [Aurora_Serverless-V2/README.md](./Aurora_Serverless-V2/README.md) を参照してください。

主な構成要素:
- VPC（プライベートサブネット×2）
- Aurora Serverless V2 クラスター
- Aurora インスタンス
- セキュリティグループ

スケーリング設定:
- 最小ACU: 0（利用なし時はコスト0）
- 最大ACU: 4（db.m5d.large相当）

## 前提条件

### 必要なツール

- Terraform: v1.0以上
  ```bash
  terraform version
  ```

- AWS CLI: v2.0以上
  ```bash
  aws --version
  ```

### AWS認証情報

以下のいずれかの方法でAWS認証情報を設定してください：

```bash
# AWS CLIの設定
aws configure

# または環境変数
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-1"
```

### 必要なIAM権限

- VPC、サブネット、セキュリティグループの作成・管理
- RDS/Auroraの作成・管理
- EventBridge Schedulerの作成・管理（パターン1のみ）
- IAMロール・ポリシーの作成・管理

## クイックスタート

### パターン1（RDS自動停止）の場合

```bash
# リポジトリのクローン
git clone https://github.com/your-username/terraform-rds-weekend-cost-optimization.git
cd terraform-rds-weekend-cost-optimization/Terraform/Automatically_Schedule_Shutdown-Start

# 変数ファイルの作成
cp terraform.tfvars.example terraform.tfvars

# 変数の編集（パスワードは必ず変更）
vi terraform.tfvars

# Terraformの初期化
terraform init

# プランの確認
terraform plan

# リソースの作成
terraform apply
```

### パターン2（Aurora Serverless V2）の場合

```bash
# リポジトリのクローン
git clone https://github.com/your-username/terraform-rds-weekend-cost-optimization.git
cd terraform-rds-weekend-cost-optimization/Terraform/Aurora_Serverless-V2

# 変数ファイルの作成
cp terraform.tfvars.example terraform.tfvars

# 変数の編集（パスワードは必ず変更）
vi terraform.tfvars

# Terraformの初期化
terraform init

# プランの確認
terraform plan

# リソースの作成
terraform apply
```

## 注意事項

### セキュリティ

#### パスワード管理

- `terraform.tfvars`は`.gitignore`に追加済み（絶対にコミットしないこと）
- 本番環境では環境変数またはAWS Secrets Managerを使用してください

```bash
# 環境変数でパスワードを設定（推奨）
export TF_VAR_master_password="YourSecurePassword123!"
export TF_VAR_rds_password="YourSecurePassword123!"
terraform apply
```

#### ネットワークセキュリティ

- RDS/Auroraはプライベートサブネットに配置
- パブリックアクセスは無効化
- VPC内からのみアクセス可能

### RDSの7日間制限（パターン1）

- RDSは停止後7日間で自動的に起動されます
- 長期休暇（GW、お盆、年末年始）では7日以内に一度起動されます
- 長期間停止したい場合は、スナップショットを取得してインスタンスを削除することを検討してください

### 初回接続の遅延（パターン2）

- 最小ACU 0の場合、初回アクセス時に数秒の遅延が発生します
- アプリケーション側で接続タイムアウトを30秒以上に設定してください
- リトライロジックの実装を推奨します

## トラブルシューティング

各パターンの詳細なトラブルシューティングは、それぞれのREADMEを参照してください：

- [パターン1のトラブルシューティング](./Automatically_Schedule_Shutdown-Start/README.md#トラブルシューティング)
- [パターン2のトラブルシューティング](./Aurora_Serverless-V2/README.md#トラブルシューティング)

## リソースの削除

### パターン1の削除

```bash
cd Automatically_Schedule_Shutdown-Start
terraform destroy
```

### パターン2の削除

```bash
cd Aurora_Serverless-V2
terraform destroy
```

### 削除保護が有効な場合

```bash
# RDSの場合
aws rds modify-db-instance \
  --db-instance-identifier <your-identifier> \
  --no-deletion-protection \
  --apply-immediately

# Auroraの場合
aws rds modify-db-cluster \
  --db-cluster-identifier <your-identifier> \
  --no-deletion-protection \
  --apply-immediately

# 削除を実行
terraform destroy
```

## 参考リンク

### AWS公式ドキュメント
- [Amazon RDS User Guide](https://docs.aws.amazon.com/rds/)
- [Aurora Serverless V2 公式ドキュメント](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
- [EventBridge Scheduler User Guide](https://docs.aws.amazon.com/scheduler/)

### 料金情報
- [Amazon RDS 料金](https://aws.amazon.com/jp/rds/mysql/pricing/)
- [Amazon Aurora 料金](https://aws.amazon.com/jp/rds/aurora/pricing/)
- [AWS Pricing Calculator](https://calculator.aws/)

### Terraform
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### 関連記事
- [【5分で簡単！】Amazon EventBridge SchedulerでRDSの自動定期停止を実装してみた](https://dev.classmethod.jp/articles/amazon-eventbridge-scheduler-rds-stop/)

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

