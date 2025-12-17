# Blog App

A small React + Vite blog application scaffold that demonstrates creating posts, viewing them in a dashboard, and a simple profile page. This repository contains the UI and components for a single-page app built with Vite and React.

**Status:** Minimal example / starter template for a blog UI.

**Built with:** React, Vite, plain CSS.

## Features

- Create and preview posts (client-side only)
- Dashboard to list posts
- Simple profile view

## Tech Stack

- React (JSX)
- Vite (dev server + build)
- Plain CSS for styling

## Project Structure

- `index.html` - App entry HTML
- `src/main.jsx` - React entry, mounts the app
- `src/App.jsx` - Top-level app component
- `src/components/` - UI components (`CreatePost.jsx`, `Dashboard.jsx`, `Profile.jsx`)
- `src/assets/` - Static assets
- `public/` - Static files served by Vite

## Getting Started

Prerequisites: Node.js (18+ recommended) and npm.

Install dependencies and start the dev server:

```powershell
npm install
npm run dev
```

Open the app in your browser at `http://localhost:5173` (Vite prints the URL after starting).

Build for production:

```powershell
npm run build
npm run preview
```

## Notes

- This project is a frontend-only example. There is no backend persistence for posts — data is kept in component state.
- If you see a blank page when running the dev server, open the browser console and the terminal running `npm run dev` to check for compilation or runtime errors.

## Contributing

Feel free to open issues, add features, or adapt this template for your own blog projects.

## License

This project is provided as-is. Add a license if you plan to publish or share broadly.

"# Dentify-app"  
