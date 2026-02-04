#!/bin/bash

# Script para atualizar Discord manualmente no Omarchy/Arch Linux
# Uso: ./atualizar-discord.sh /caminho/para/Discord-X.X.XXX.tar.gz

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se foi passado o arquivo tar.gz como argumento
if [ $# -eq 0 ]; then
    echo -e "${RED}Erro: Nenhum arquivo especificado!${NC}"
    echo "Uso: $0 /caminho/para/Discord-X.X.XXX.tar.gz"
    exit 1
fi

DISCORD_TARBALL="$1"

# Verifica se o arquivo existe
if [ ! -f "$DISCORD_TARBALL" ]; then
    echo -e "${RED}Erro: Arquivo '$DISCORD_TARBALL' não encontrado!${NC}"
    exit 1
fi

# Verifica se o arquivo é tar.gz
if [[ ! "$DISCORD_TARBALL" =~ \.tar\.gz$ ]]; then
    echo -e "${RED}Erro: O arquivo deve ser um .tar.gz${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Atualizador de Discord ===${NC}"
echo -e "${YELLOW}Arquivo: $DISCORD_TARBALL${NC}\n"

# Cria diretório temporário
TEMP_DIR=$(mktemp -d)
echo -e "${GREEN}[1/7]${NC} Criando diretório temporário..."

# Extrai o arquivo
echo -e "${GREEN}[2/7]${NC} Extraindo arquivo tar.gz..."
tar -xzf "$DISCORD_TARBALL" -C "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao extrair arquivo!${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Verifica se a pasta Discord foi extraída
if [ ! -d "$TEMP_DIR/Discord" ]; then
    echo -e "${RED}Erro: Pasta 'Discord' não encontrada no arquivo!${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Remove instalação antiga
echo -e "${GREEN}[3/7]${NC} Removendo instalação antiga..."
sudo rm -rf /opt/Discord

# Move nova versão
echo -e "${GREEN}[4/7]${NC} Instalando nova versão..."
sudo mv "$TEMP_DIR/Discord" /opt/

# Cria link simbólico
echo -e "${GREEN}[5/7]${NC} Criando link simbólico..."
sudo ln -sf /opt/Discord/Discord /usr/bin/discord

# Cria arquivo .desktop
echo -e "${GREEN}[6/7]${NC} Criando arquivo .desktop..."
sudo tee /usr/share/applications/discord.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers
GenericName=Internet Messenger
Exec=/opt/Discord/Discord
Icon=/opt/Discord/discord.png
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
EOF

# Atualiza cache
echo -e "${GREEN}[7/7]${NC} Atualizando cache de aplicativos..."
sudo update-desktop-database

# Limpa diretório temporário
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✓ Discord atualizado com sucesso!${NC}"
echo -e "Você pode abrir o Discord pelo menu de aplicativos ou digitando: ${YELLOW}discord${NC}\n"