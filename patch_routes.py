import re

with open('frontend/lib/app.dart', 'r') as f:
    content = f.read()

# Add route for vidiq-alternative-free
content = content.replace(
    "Route(path: '/about', builder: (context, state) => _buildAbout()),",
    "Route(path: '/vidiq-alternative-free', builder: (context, state) => div([])),\n            Route(path: '/about', builder: (context, state) => _buildAbout()),"
)

with open('frontend/lib/app.dart', 'w') as f:
    f.write(content)

