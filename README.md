# Customizable Chart Flutter App

<div align="center">

<p align="center">
  <a href="#english">🇺🇸 English</a> •
  <a href="#português">🇧🇷 Português</a>
</p>

---

## English

A Flutter application that allows chart customization through natural language text prompts, supporting both intelligent AI processing and predefined commands.

</div>

### ✨ Key Features

- 📊 **Interactive Line Chart** - Customizable chart with smooth animations
- 🎨 **Real-time Styling** - Change colors, thickness, and visual properties instantly
- 💬 **Natural Language Processing** - Control charts using intuitive text commands
- 🤖 **AI Integration** - Advanced prompt processing with OpenAI API
- 🌐 **Bilingual Support** - Complete localization in English and Portuguese
- ⚙️ **Smart Settings** - Easy API key management with secure storage
- 📱 **Responsive Design** - Modern UI that works on all screen sizes

### 📱 App Preview

#### English Interface
<div align="center">
<img src="previews/eng/chart_page.PNG" alt="Chart Page (English)" width="300"/>
<img src="previews/eng/settings_page.PNG" alt="Settings Page (English)" width="300"/>
</div>

### 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/customizable_chart.git
   cd customizable_chart
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### 🎯 Usage Examples

#### Built-in Commands
Try these preset prompts for immediate results:
- `"make it red and bold"` - Creates a bold red line chart
- `"show sales data in blue"` - Generates blue-themed sales visualization
- `"create minimal chart with grid"` - Minimalist design with grid lines
- `"bright orange trending view"` - Dynamic orange trending visualization
- `"purple theme with thick lines"` - Purple styling with enhanced line thickness

#### AI-Powered Commands (with API key)
With OpenAI API configured, use more complex natural language:
- `"Change the chart to green with a gradient background"`
- `"Make the line thicker and add more data points"`
- `"Create a professional blue theme for presentation"`
- `"Use warm colors with elegant styling"`

### ⚙️ AI Configuration

To unlock advanced AI features:

1. **Get your OpenAI API Key**
   - Visit [OpenAI API Keys](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the generated key

2. **Configure in the app**
   - Open the Settings page (⚙️ icon)
   - Enter your API key in the "OpenAI API Key" field
   - Tap "Save Key"

3. **Start using AI commands**
   - The app will automatically use AI for complex prompts
   - Fallback to built-in commands if API is unavailable

### 🏗️ Architecture

```
lib/
├── main.dart                          # Application entry point
├── injector.dart                      # Dependency injection setup  
├── model/
│   ├── models/
│   │   └── chart_data_model.dart     # Chart data model
│   ├── repositories/
│   │   └── llm_repository.dart       # AI service integration
│   └── services/                     # Core services
├── view/
│   ├── chart_page.dart              # Main chart page
│   ├── settings_page.dart           # Settings configuration
│   └── components/                  # Reusable UI components
├── viewmodel/                       # State management
└── l10n/                           # Internationalization files
```

### 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - Cross-platform UI framework
- **[fl_chart](https://pub.dev/packages/fl_chart)** - Beautiful chart library
- **[get_it](https://pub.dev/packages/get_it)** - Dependency injection
- **[dio](https://pub.dev/packages/dio)** - HTTP client for API calls
- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)** - Secure key storage

---

## Português

<div align="center">

Um aplicativo Flutter que permite customizar gráficos através de prompts de texto em linguagem natural, suportando processamento inteligente com IA e comandos predefinidos.

</div>

### ✨ Funcionalidades Principais

- 📊 **Gráfico de Linha Interativo** - Gráfico customizável com animações suaves
- 🎨 **Estilização em Tempo Real** - Altere cores, espessura e propriedades visuais instantaneamente
- 💬 **Processamento de Linguagem Natural** - Controle gráficos usando comandos de texto intuitivos
- 🤖 **Integração com IA** - Processamento avançado de prompts com API da OpenAI
- 🌐 **Suporte Bilíngue** - Localização completa em inglês e português
- ⚙️ **Configurações Inteligentes** - Gerenciamento fácil de chaves API com armazenamento seguro
- 📱 **Design Responsivo** - Interface moderna que funciona em todos os tamanhos de tela

### 📱 Visualização do App

#### Interface em Português
<div align="center">
<img src="previews/br/chart_page.PNG" alt="Página do Gráfico (Português)" width="300"/>
<img src="previews/br/settings_page.PNG" alt="Página de Configurações (Português)" width="300"/>
</div>

### 🚀 Início Rápido

1. **Clone o repositório**
   ```bash
   git clone https://github.com/yourusername/customizable_chart.git
   cd customizable_chart
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o app**
   ```bash
   flutter run
   ```

### 🎯 Exemplos de Uso

#### Comandos Integrados
Experimente estes prompts predefinidos para resultados imediatos:
- `"deixe vermelho e grosso"` - Cria um gráfico de linha vermelha em negrito
- `"mostre dados de vendas em azul"` - Gera visualização de vendas com tema azul
- `"crie gráfico minimalista com grade"` - Design minimalista com linhas de grade
- `"visão laranja vibrante crescente"` - Visualização dinâmica laranja crescente
- `"tema roxo com linhas grossas"` - Estilo roxo com espessura de linha aprimorada

#### Comandos com IA (com chave API)
Com a API da OpenAI configurada, use linguagem natural mais complexa:
- `"Mude o gráfico para verde com fundo gradiente"`
- `"Deixe a linha mais grossa e adicione mais pontos de dados"`
- `"Crie um tema azul profissional para apresentação"`
- `"Use cores quentes com estilo elegante"`

### ⚙️ Configuração da IA

Para desbloquear recursos avançados de IA:

1. **Obtenha sua chave da API OpenAI**
   - Visite [Chaves da API OpenAI](https://platform.openai.com/api-keys)
   - Crie uma nova chave API
   - Copie a chave gerada

2. **Configure no app**
   - Abra a página de Configurações (ícone ⚙️)
   - Digite sua chave API no campo "Chave da API OpenAI"
   - Toque em "Salvar Chave"

3. **Comece a usar comandos de IA**
   - O app usará automaticamente IA para prompts complexos
   - Fallback para comandos integrados se a API estiver indisponível

### 🏗️ Arquitetura

```
lib/
├── main.dart                          # Ponto de entrada da aplicação
├── injector.dart                      # Configuração de injeção de dependência
├── model/
│   ├── models/
│   │   └── chart_data_model.dart     # Modelo de dados do gráfico
│   ├── repositories/
│   │   └── llm_repository.dart       # Integração com serviço de IA
│   └── services/                     # Serviços principais
├── view/
│   ├── chart_page.dart              # Página principal do gráfico
│   ├── settings_page.dart           # Configurações
│   └── components/                  # Componentes de UI reutilizáveis
├── viewmodel/                       # Gerenciamento de estado
└── l10n/                           # Arquivos de internacionalização
```

### 🛠️ Construído Com

- **[Flutter](https://flutter.dev/)** - Framework de UI multiplataforma
- **[fl_chart](https://pub.dev/packages/fl_chart)** - Biblioteca de gráficos bonitos
- **[get_it](https://pub.dev/packages/get_it)** - Injeção de dependência
- **[dio](https://pub.dev/packages/dio)** - Cliente HTTP para chamadas de API
- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)** - Armazenamento seguro de chaves

### 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### 🔒 Segurança

- ⚠️ **Nunca faça commit de sua chave API no repositório**
- ✅ Chaves API são armazenadas com segurança no dispositivo
- ✅ Use variáveis de ambiente para dados sensíveis
- ✅ Considere usar secrets do CI/CD para deployment

### 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

<div align="center">
<p>Feito com ❤️ usando Flutter</p>
</div>