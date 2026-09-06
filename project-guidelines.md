# YouTube Creator Tool - Project Guidelines & Architecture

## 1. Project Overview
This project is a web-based suite of tools for YouTube creators, including SEO analysis, title generation, thumbnail ideas, tag extraction, and earnings calculation. It relies on a Dart (Jaspr) frontend and a Python backend.

## 2. Architecture

### Frontend (Dart / Jaspr)
- **Framework**: Jaspr (Server-Side Generation / Static Site Generation mode).
- **Routing**: Managed by `jaspr_router` to support 11 distinct paths (e.g., `/youtube-seo-analyzer`).
- **Styling**: Tailwind CSS.
- **Island Architecture / SSG**: 
  - To support SEO and `curl` fetching, the site is compiled to static HTML (`jaspr build --mode static`).
  - Browser-specific code (`dart:js_interop`) for ReCAPTCHA, AdSense, and consent banners must be abstracted via conditional imports (e.g., `client_interop.dart`) to ensure the server compilation succeeds.

### Backend (Python)
- **Framework**: Flask / FastAPI.
- **Security**: 
  - Endpoints should require a ReCAPTCHA token (`X-Recaptcha-Token`) passed in the headers.
  - Secret keys (e.g., Gemini API keys) must be loaded from environment variables, not hardcoded.
- **AI Integration**: Uses Gemini for intelligent text generation and processing.

## 3. Development Rules & Guidelines

- **No Hardcoded Secrets**: Never commit `.env` files or hardcode API keys. Use environment variables.
- **Frontend Interop**: Any usage of `window`, `document`, or `dart:js_interop` MUST be placed behind conditional imports so `jaspr build` on the server does not fail.
- **Translations**: Text should be added to `i18n_service.dart` to support localization.
- **Component Reusability**: Extract large UI segments into separate Jaspr `Component` classes.

## 4. Deployment
- **Target**: Hetzner Server.
- **Frontend**: Served statically (e.g., via Nginx) from the `frontend/build/jaspr` directory.
- **Backend**: Managed via a service or container, running the Python application.
- **CI/CD**: Managed via `Jenkinsfile` or GitHub Actions. Always ensure tests pass before deployment.
