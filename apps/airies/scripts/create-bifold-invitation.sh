#!/bin/bash
curl -X POST http://localhost:3001/connections/create-invitation \
  -H "Content-Type: application/json" \
  -d '{"alias":"bifold-user","auto_accept":true}'
