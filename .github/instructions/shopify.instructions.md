---
name: 'Shopify Integration'
description: 'Shopify API patterns and best practices for comic retail projects'
---

# Shopify Integration Patterns

## Apply when working on Shopify/comic retail projects

### API Usage
- Use Shopify Admin GraphQL API (not REST) for all operations
- Bulk operations for large data sets (products, inventory)
- Rate limit awareness — implement retry with backoff
- Webhook subscriptions for real-time updates

### Product Management
- CLZ XML as source of truth for comic inventory
- Barcode-based matching between CLZ and Shopify
- Batch upload with preview mode before committing
- Image handling: download from CLZ, upload to Shopify CDN

### Data Patterns
- Product metafields for comic-specific data (publisher, issue number, grade)
- Variant handling for different conditions (NM, VF, FN, etc.)
- Collection auto-rules based on publisher/series
- Inventory locations mapping (box locations from CLZ)

### eBay Integration
- Fuzzy matching with exact issue number requirement
- Cover image display from CLZ XML
- Print-friendly pick lists for shipping
- Order reconciliation between platforms

### Authentication
- Shopify access tokens stored in .env (gitignored)
- Use VS Code input variables for MCP server config
- Never hardcode tokens in mcp.json or code
- Rotate tokens periodically
