# App Store Connect — Privacy & Support URLs

After publishing to GitHub Pages, use these URLs in App Store Connect.

## URLs (replace `YOUR_USERNAME` and `YOUR_REPO` with your GitHub details)

| Field | URL |
|-------|-----|
| **Privacy Policy URL** | `https://YOUR_USERNAME.github.io/YOUR_REPO/privacy-policy.html` |
| **Support URL** | `https://YOUR_USERNAME.github.io/YOUR_REPO/support.html` |

### Example
If your repo is `https://github.com/johndoe/whatthebug`, then:
- **Privacy Policy:** `https://johndoe.github.io/whatthebug/privacy-policy.html`
- **Support:** `https://johndoe.github.io/whatthebug/support.html`

## Where to add in App Store Connect

1. **App Store Connect** → Your App → **App Information**
2. Under **App Information**, find:
   - **Privacy Policy URL** — paste your privacy policy URL
   - **Support URL** — paste your support URL
3. **Marketing URL** (optional): You can use `https://YOUR_USERNAME.github.io/YOUR_REPO/` or leave blank.

## One-time setup: Enable GitHub Pages

1. Push this repo to GitHub (create a new repo if needed)
2. **GitHub** → Your repo → **Settings** → **Pages**
3. Under **Build and deployment**:
   - **Source:** Deploy from a branch
   - **Branch:** `main` (or your default branch)
   - **Folder:** `/docs`
4. Click **Save**
5. Wait 1–2 minutes — your pages will be live at the URLs above

## Update support email

Edit `docs/support.html` and replace `support@whatthebug.app` with your real support email if different.
