# The Blog Platform — Application Overview

This document describes the navigation and core functionality of the web
application as observed from the running product. No supporting documentation
was provided; everything below is based on exploring the application "as is."

The application is a small multi-user blogging platform: visitors can browse
and read posts, registered users can write and manage their own posts, and a
simple plans-and-pricing page is available to signed-in users.

---

## Navigation

Every page shares a common header at the top of the screen:

- **Home** — returns to the list of posts (the landing page).
- **Sign in / Sign up** — shown to visitors who are not logged in.
- **Logged in as `<email>` · Profile · Log out** — shown once a user is
  signed in, identifying the current account and giving access to account
  settings and logout.
- **See our plans & pricing** — a link to the subscription plans page,
  visible to everyone (opening it requires signing in).

The landing page (`/`) is the post list, so browsing the blog is the default
entry point into the application.

## Access levels

- **Public** — the post list, individual post pages, search, and the account
  entry points (sign in, sign up, password recovery).
- **Requires sign in** — creating, editing, and deleting posts; the profile
  and account-cancellation screens; and the plans & pricing page.
- **Owner only** — a post can only be edited or deleted by the user who
  wrote it.

---

## Core features

### Accounts and authentication

- **Sign up** — Visitors can create an account with an email address and a
  password (minimum six characters); registration signs them in immediately.
- **Sign in** — Registered users log in with their email and password, with an
  optional "remember me" option that keeps them signed in across sessions.
- **Log out** — Ends the current session and returns to the public post list.
- **Profile / account settings** — Signed-in users can change their email or
  password from the profile screen; confirming any change requires re-entering
  the current password.
- **Cancel account** — The same profile screen offers a "Cancel my account"
  action that permanently deletes the account after a confirmation prompt.
- **Password recovery** — A "Forgot your password?" flow lets users request a
  reset link by email and set a new password.

### Blog posts

- **Browse posts** — The home page lists all posts, each showing its title,
  publication date, and body; it is open to visitors without an account.
- **Read a post** — Each post has its own page showing the full formatted body.
- **Search** — A search box on the post list filters posts whose title or body
  contains the entered text.
- **Create a post** — Signed-in users can write a post with a title (5–100
  characters) and a body; the body is entered through a rich text editor with
  formatting tools (bold, italic, headings, lists, links, and more), so no HTML
  knowledge is required. Both fields are required.
- **Formatted content** — Post bodies keep their formatting, which is cleaned
  before display so that safe formatting is kept while scripts and other unsafe
  markup are removed.
- **Edit a post** — Authors can update the title and body of their own posts;
  edit and delete controls appear only on posts the current user wrote.
- **Delete a post** — Authors can permanently remove their own posts after a
  confirmation prompt.

### Plans and pricing

- **Plans page** — Signed-in users can view two subscription options, a Monthly
  plan ($5/month) and a Yearly plan ($50/year, advertised as 16.6% off), each
  with a "Contact us" link that opens an email to the sales address.
- **Live currency conversion** — Each plan's price is also shown in Czech
  koruna (CZK), converted from USD using the European Central Bank's daily
  exchange rates.
