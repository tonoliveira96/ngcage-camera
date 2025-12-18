# 📷 NCage Camera – Offline AI Object Detection (Flutter + TFLite)

Aplicativo mobile desenvolvido em **Flutter** que utiliza **Inteligência Artificial offline** para análise de imagens capturadas pela câmera do dispositivo.

O projeto foi criado com foco em **aprendizado**, **experimentação com IA embarcada** e possibilidade real de **publicação na Play Store**.

![Nicolas Cage and Pedro Pascal](https://i.makeagif.com/media/3-07-2023/uToqRn.gif)
---

## 🚀 Funcionalidades

* 📸 Captura de fotos usando a câmera nativa
* 🤖 Detecção de objetos/pessoas usando **IA offline (TFLite)**
* 📴 Funciona **sem internet**
* 💾 Salvamento de imagens na galeria
* 🔐 Respeita permissões do Android
* 🧠 Modelo treinado customizadamente

> Exemplo de uso atual: permitir a captura **somente quando um personagem específico é detectado**.

---

## 🛠️ Tecnologias utilizadas

### Mobile

* Flutter (Dart)
* Camera plugin
* TensorFlow Lite
* Permission Handler

### IA / Machine Learning

* Python
* TensorFlow / Keras
* Google Colab
* Transfer Learning (MobileNet)
* Conversão para `.tflite`

---

## 🧠 Treinamento do modelo

O modelo é treinado utilizando **imagens organizadas por classe**, no formato esperado pelo TensorFlow:

```text
datasets/
 ├── cage/
 │    ├── img_001.jpg
 │    ├── img_002.jpg
 └── not_cage/
      ├── img_001.jpg
      ├── img_002.jpg
```

Fluxo:

1. Download das imagens
2. Limpeza (extensão, corrupção, qualidade)
3. Treinamento
4. Validação
5. Conversão para TFLite
6. Integração no app Flutter

---

## 📱 Executando o app

### Pré-requisitos

* Flutter instalado
* Android Studio ou VS Code
* Emulador ou dispositivo físico

```bash
flutter pub get
flutter run
```

---

## 🔐 Permissões utilizadas

* 📷 Câmera
* 💾 Armazenamento (para salvar imagens)

Todas as permissões são utilizadas **exclusivamente para funcionamento do app**.

---

## 📄 Política de Privacidade

A política de privacidade está disponível no arquivo:

➡️ [`PRIVACY_POLICY.md`](./PRIVACY_POLICY.md)

Ela pode ser reutilizada em outros projetos.

---

## ⚠️ Aviso legal

Este projeto é **educacional e experimental**.

* Nenhuma imagem é enviada para servidores
* Nenhum dado pessoal é coletado
* Toda a análise acontece localmente no dispositivo

---

## 🤝 Contribuições

Contribuições são bem-vindas!

* Sugestões
* Correções
* Melhorias de performance
* Novos modelos

Abra uma *issue* ou *pull request* 🚀

---

## 📜 Licença

Este projeto está sob a licença **MIT**.

---

## 👨‍💻 Autor

Desenvolvido por [**Everton (Ton)**](https://www.linkedin.com/in/tonoliveira96/)

* Flutter & Mobile
* IA embarcada
* Fullstack

---

⭐ Se este projeto te ajudou, deixe uma estrela no repositório!
