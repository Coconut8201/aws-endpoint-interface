![SQS](images/image3.png)

## 為何需要使用 VPC Endpoint？

### 問題：沒有 VPC Endpoint 會發生什麼？

當 VPC 內的資源（如 EC2）需要存取 AWS 服務（如 SQS）時，有兩種方式：

**1. 透過公網存取（無 VPC Endpoint）**
```
EC2 → Internet Gateway → 公網 → AWS SQS 服務端點
```
問題：
- 流量必須經過公網，即使 EC2 和 SQS 都在 AWS 內部
- 需要配置 Internet Gateway 或 NAT Gateway
- 私有子網路中的 EC2 無法直接存取（除非透過 NAT）
- 資料傳輸經過公網，安全性較低
- 可能產生額外的數據傳輸費用

**2. 透過 VPC Endpoint 存取（推薦）**
```
EC2 → VPC Endpoint → AWS 骨幹網路 → AWS SQS 服務
```
優勢：
- ✅ **流量完全在 AWS 內部網路**，不經過公網
- ✅ **提高安全性**：敏感資料不會暴露在公網
- ✅ **降低延遲**：使用 AWS 內部骨幹網路
- ✅ **簡化網路架構**：私有子網路不需要 NAT Gateway
- ✅ **降低成本**：避免 NAT Gateway 的費用（Gateway Endpoint 更是完全免費）
- ✅ **符合合規要求**：某些產業要求資料不能經過公網

### 使用場景範例

**場景 1：金融服務應用**
- 需求：處理敏感的交易資料
- 解決方案：使用 VPC Endpoint 確保所有資料在 AWS 內部網路傳輸
- 結果：符合 PCI DSS 等合規標準

**場景 2：高可用性微服務架構**
- 需求：多個微服務需要透過 SQS 通訊
- 解決方案：所有服務部署在私有子網路，透過 VPC Endpoint 存取 SQS
- 結果：降低延遲、提高可靠性、節省 NAT Gateway 成本

## VPC Endpoint 類型比較

AWS VPC Endpoint 有兩種類型，本專案使用的是 **Interface Endpoint**。

### Interface Endpoint vs Gateway Endpoint

| 特性 | Interface Endpoint | Gateway Endpoint |
|------|-------------------|------------------|
| **實作方式** | 在 VPC 子網路中建立 ENI (彈性網路介面) | 在路由表中添加路由規則 |
| **私有 IP** | 有私有 IP 地址 | 無私有 IP |
| **Private DNS** | 支援，可自動解析服務域名到私有 IP | 不支援 |
| **安全群組** | 需要關聯安全群組進行流量控制 | 不需要安全群組 |
| **支援的服務** | 大多數 AWS 服務 (SQS, SNS, Secrets Manager 等) | **只支援 S3 和 DynamoDB** |
| **費用** | 按小時和數據傳輸量計費 | **完全免費** |
| **可用區** | 每個子網路建立一個 ENI | 不依賴可用區 |
| **流量路徑** | 流量透過 ENI 進入 AWS 骨幹網路 | 流量透過路由表直接路由 |

### 為什麼本專案使用 Interface Endpoint？

因為 **SQS 只支援 Interface Endpoint**，不支援 Gateway Endpoint。

在 Terraform 程式碼中明確指定：
```hcl
resource "aws_vpc_endpoint" "sqs" {
  vpc_endpoint_type = "Interface"  # SQS 必須使用 Interface 類型
  service_name      = "com.amazonaws.${var.region}.sqs"
  # ...
}
```

### 何時使用 Gateway Endpoint？

如果你的應用需要存取 **S3** 或 **DynamoDB**，建議使用 Gateway Endpoint，因為：
- 完全免費
- 配置簡單
- 不需要管理 ENI 或安全群組

範例：
```hcl
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"  # S3 可以使用 Gateway
  route_table_ids = [aws_route_table.private.id]
}
```

## 使用 VPC Endpoint 時的 VPC 內部設定限制

### Interface Endpoint 的設定要求

#### 1. **子網路要求**
```hcl
# 必須指定至少一個子網路
subnet_ids = [aws_subnet.private.id]
```
限制：
- 每個可用區最多建立一個 ENI
- 子網路必須有足夠的可用 IP 地址（每個 Endpoint 至少需要一個 IP）
- 建議在多個可用區建立 Endpoint 以提高可用性

#### 2. **安全群組要求**
```hcl
# 必須關聯安全群組控制流量
security_group_ids = [aws_security_group.endpoint_sg.id]
```

**重要限制**：安全群組必須允許來自 VPC 內部的流量

範例安全群組規則：
```hcl
resource "aws_security_group" "endpoint_sg" {
  vpc_id = aws_vpc.main.id

  # 允許 HTTPS 流量（443 port）
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]  # 允許整個 VPC 的流量
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

❌ **常見錯誤**：忘記在安全群組開放 443 port，導致無法連線到 Endpoint

#### 3. **Private DNS 設定**
```hcl
private_dns_enabled = true  # 建議啟用
```

**啟用 Private DNS 的影響**：
- ✅ AWS SDK/CLI 可以使用標準的服務端點（如 `sqs.ap-northeast-1.amazonaws.com`）
- ✅ 自動解析到 VPC Endpoint 的私有 IP
- ✅ 不需要修改應用程式程式碼

**不啟用 Private DNS 的影響**：
- ❌ 必須使用 VPC Endpoint 專屬的 DNS 名稱
- ❌ 需要修改應用程式的連線設定
- ❌ 增加維護複雜度

#### 4. **VPC DNS 設定要求**

啟用 Private DNS 前，VPC 必須啟用以下設定：
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true  # 必須啟用
  enable_dns_hostnames = true  # 必須啟用
}
```

❌ **限制**：如果 VPC 未啟用 DNS support 或 DNS hostnames，無法使用 Private DNS

### Gateway Endpoint 的設定要求

#### 1. **路由表要求**
```hcl
# 必須指定要關聯的路由表
route_table_ids = [aws_route_table.private.id]
```

**AWS 會自動在路由表中添加路由規則**：
```
目的地: pl-xxxxxxxx (S3 或 DynamoDB 的 prefix list)
目標: vpce-xxxxxxxx (VPC Endpoint ID)
```

#### 2. **子網路要求**
- ❌ Gateway Endpoint **不需要**指定子網路
- ✅ 透過路由表自動套用到所有關聯的子網路

#### 3. **安全群組**
- ❌ Gateway Endpoint **不支援**安全群組
- ✅ 使用網路 ACL 或 S3/DynamoDB 的資源政策控制存取

#### 4. **Private DNS**
- ❌ Gateway Endpoint **不支援** Private DNS
- ✅ 直接透過路由表路由流量

### VPC Endpoint Policy 限制

兩種 Endpoint 都可以設定 Endpoint Policy 來限制存取：

```hcl
policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect    = "Allow"
      Principal = "*"
      Action    = ["sqs:SendMessage", "sqs:ReceiveMessage"]
      Resource  = "arn:aws:sqs:ap-northeast-1:123456789012:my-queue"
      Condition = {
        StringEquals = {
          "aws:PrincipalAccount" = "123456789012"  # 限制只有此帳號可存取
        }
      }
    }
  ]
})
```

**注意**：
- Endpoint Policy 不會取代 IAM 政策或資源政策
- 必須同時滿足 IAM 政策 + Endpoint Policy + 資源政策才能存取
- 預設的 Endpoint Policy 允許所有流量

### 費用相關限制

#### Interface Endpoint
- 按小時計費：每個 Endpoint 每小時約 $0.01 USD
- 數據傳輸費用：每 GB 約 $0.01 USD
- **建議**：避免建立過多不必要的 Endpoint

#### Gateway Endpoint
- ✅ 完全免費
- ✅ 無數據傳輸費用
- **建議**：S3 和 DynamoDB 優先使用 Gateway Endpoint

### 最佳實踐檢查清單

使用 Interface Endpoint 時，確保：
- ✅ VPC 已啟用 DNS support 和 DNS hostnames
- ✅ 安全群組允許 443 port 的入站流量
- ✅ 子網路有足夠的可用 IP
- ✅ 啟用 Private DNS（除非有特殊需求）
- ✅ 為高可用性配置多個可用區的 Endpoint

使用 Gateway Endpoint 時，確保：
- ✅ 已將 Endpoint 關聯到正確的路由表
- ✅ 檢查路由表是否已自動添加路由規則
- ✅ 使用網路 ACL 或資源政策控制存取

## 什麼是 SQS
SQS 是 Amazon 提供的隊列服務，可以讓不同應用程式之間進行非同步通訊。它允許您將訊息發送到隊列，並在後續的時間點再從隊列中讀取這些訊息。SQS 可以用於各種場景，例如工作排程、事件驅動的應用程式、微服務間的通訊等。

兩種佇列類型

1. 標準佇列(Standard Queue)
- 幾乎無限的吞吐量
- 至少一次傳遞(可能重複)
- 盡力保證順序
<br>
2. FIFO 佇列(First-In-First-Out Queue)
- 保證訊息順序
- 正好一次處理(無重複)
- 吞吐量較標準佇列低(每秒最多 3000 則訊息)

沒有連線 vpc時使用：
```bash
aws sqs send-message \
  --queue-url "$SQS_QUEUE_URL" \
  --message-body "測試訊息 rrr" \
  --region ap-northeast-1a
```
![SQS](images/image2.png)

## 設定 EC2 Instance Profile

使用 VPC 中的 EC2 進行連線測試前，需要先附加 IAM Instance Profile 給 EC2 實例。

### 1. 執行 Terraform 建立 IAM 資源

```bash
terraform apply
```

執行後會輸出 `ec2_instance_profile_name`，例如：`coco-endpoint-vpc-ec2-profile`

### 2. 附加 Instance Profile 到現有的 EC2

**方法 A: 透過 AWS Console**
1. 進入 EC2 Console
2. 選擇你的 EC2 實例
3. Actions → Security → Modify IAM role
4. 選擇 `coco-endpoint-vpc-ec2-profile`
5. 點擊 Update IAM role

**方法 B: 透過 AWS CLI**
```bash
# 取得 instance profile 名稱
terraform output ec2_instance_profile_name

# 附加到 EC2 (替換 i-xxxxx 為你的 instance ID)
aws ec2 associate-iam-instance-profile \
  --instance-id i-xxxxx \
  --iam-instance-profile Name=coco-endpoint-vpc-ec2-profile
```

### 3. 在 EC2 上測試 SQS 連線

附加 Instance Profile 後，**不需要執行 `aws configure` 或提供任何憑證**，EC2 會自動使用 IAM Role 的權限。

```bash
# 直接執行，無需登入
aws sqs send-message \
  --queue-url "$SQS_QUEUE_URL" \
  --message-body "測試訊息 from VPC" \
  --region ap-northeast-1
```

注意：區域參數應該是 `ap-northeast-1`，不是 `ap-northeast-1a` (後者是 availability zone)

![SQS](images/image4.png)
