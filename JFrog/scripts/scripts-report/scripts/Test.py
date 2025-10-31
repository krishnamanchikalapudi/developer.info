html_content = """
<!DOCTYPE html>
<html>
<head>
    <title>Python Generated HTML</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; }
        h1 { color: blue; }
    </style>
</head>
<body>
    <h1>Hello from Python!</h1>
    <p>This HTML page was generated using Python and deployed via GitHub Actions.</p>
</body>
</html>
"""

# Save the generated HTML
with open("index.html", "w") as file:
    file.write(html_content)

print("index.html generated successfully!")
