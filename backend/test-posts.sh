URL="http://localhost:3000/posts"

for i in $(seq 1 15); do
  TITLE="TEST_post_${i}_$(date +%s)"
  DESC="TEST description #${i} - $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  USERID=$([ $((i % 3)) -eq 0 ] && echo "user_xyz" || echo "user_abc")
  ARCHIVED=$([ $((i % 5)) -eq 0 ] && echo "true" || echo "false")

  curl -s -X POST "$URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"${TITLE}\",
      \"description\": \"${DESC}\",
      \"userId\": \"${USERID}\",
      \"archived\": ${ARCHIVED}
    }" \
  | jq -r '.data.id // .'
done