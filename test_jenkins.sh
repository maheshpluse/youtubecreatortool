export ROOT_PASSWORD=$(cat env.prod.json | grep ROOT_PASSWORD | cut -d '"' -f 4)
export GEMINI_API_KEY=$(cat env.prod.json | grep GEMINI_API_KEY | cut -d '"' -f 4)

echo "Deploying Frontend..."
sshpass -p "$ROOT_PASSWORD" rsync -avz -e "ssh -o StrictHostKeyChecking=no" --delete frontend/build/jaspr/ root@157.180.22.218:/var/www/vidseokit/frontend/

echo "Deploying Backend..."
sshpass -p "$ROOT_PASSWORD" rsync -avz -e "ssh -o StrictHostKeyChecking=no" --exclude="venv" --exclude="__pycache__" backend/ root@157.180.22.218:/var/www/vidseokit/backend/

echo "Injecting Environment Variables..."
sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@157.180.22.218 "grep -q '^GEMINI_API_KEY=' /var/www/vidseokit/backend/.env 2>/dev/null && sed -i 's/^GEMINI_API_KEY=.*/GEMINI_API_KEY=$GEMINI_API_KEY/' /var/www/vidseokit/backend/.env || echo 'GEMINI_API_KEY=$GEMINI_API_KEY' >> /var/www/vidseokit/backend/.env"

echo "Restarting service..."
sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@157.180.22.218 "sudo systemctl restart vidseokit"
echo "Done!"
