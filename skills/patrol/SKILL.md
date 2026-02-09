# Patrol Cycle

Run a full system patrol in this exact order:
1. Check all hooks status
2. Scan inboxes for pending items
3. Verify convoy health and throughput
4. Inspect worker pool utilization
5. Run cleanup routines
6. Generate system health summary

Output a Markdown table with component, status, and actions taken.
Do NOT pause for confirmation between steps.
EOF
