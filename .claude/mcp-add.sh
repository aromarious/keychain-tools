#! /bin/bash
claude mcp add time-mcp uvx mcp-timeserver
claude mcp add context7-mcp -- npx -y @upstash/context7-mcp
claude mcp add Linear-mcp -- npx -y mcp-remote https://mcp.linear.app/sse
claude mcp add notion-mcp -e 'OPENAPI_MCP_HEADERS={"Authorization": "Bearer '"$(security find-generic-password -a Claude -s NOTION_CONTACT_TOKEN -w)"'","Notion-Version":"2022-06-28"}' -- npx -y @notionhq/notion-mcp-server
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=$(security find-generic-password -a $APP_NAME -s DB_USER -w)
export DB_PASSWORD=$(security find-generic-password -a $APP_NAME -s DB_PASSWORD -w)
export POSTGRES_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
claude mcp add postgres-mcp-server -- npx -y @henkey/postgres-mcp-server --connection-string "${POSTGRES_URL}"
claude mcp add drawio-mcp pnpm dlx drawio-mcp-server
