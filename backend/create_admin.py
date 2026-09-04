"""Create (or promote) an admin_panel user.

Grants the `admin` custom claim that admin_panel/src/App.tsx requires to let
someone past the login screen, and Firestore rules require for read/write
access to any admin collection.

Usage:
    python create_admin.py --email you@example.com --password 'a-strong-password'

    # Promote an existing Firebase Auth user to admin without touching their password:
    python create_admin.py --email you@example.com

Never hardcode real credentials in this file - pass them as arguments or via
the ADMIN_EMAIL / ADMIN_PASSWORD environment variables.
"""
import argparse
import os

import firebase_admin
from firebase_admin import auth, credentials

key_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
if os.path.exists(key_path):
    cred = credentials.Certificate(key_path)
    firebase_admin.initialize_app(cred)
else:
    print("Warning: serviceAccountKey.json not found, initializing with default project ID")
    firebase_admin.initialize_app(options={"projectId": "creatortools-cf7e6"})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--email", default=os.environ.get("ADMIN_EMAIL"), help="Admin email address")
    parser.add_argument(
        "--password",
        default=os.environ.get("ADMIN_PASSWORD"),
        help="Set/reset this user's password. Omit to only grant the admin claim to an existing user.",
    )
    args = parser.parse_args()

    if not args.email:
        parser.error("--email (or ADMIN_EMAIL) is required")

    try:
        user = auth.get_user_by_email(args.email)
        if args.password:
            auth.update_user(user.uid, password=args.password)
            print(f"Password updated for existing user: {user.uid}")
        else:
            print(f"Found existing user: {user.uid}")
    except auth.UserNotFoundError:
        if not args.password:
            parser.error(f"No existing user with email {args.email}; --password is required to create one")
        user = auth.create_user(email=args.email, password=args.password)
        print(f"Successfully created new user: {user.uid}")

    auth.set_custom_user_claims(user.uid, {"admin": True})
    print(f"Granted admin claim to {args.email}. They must sign out/in again for it to take effect.")


if __name__ == "__main__":
    main()
