import datetime
from google.cloud import firestore

def log_error(db, location: str, message: str, details: str = "", type_: str = "error", actor: str | None = None):
    """
    Logs an entry to the 'system_logs' collection in Firestore.

    type_ is "error" for backend failures (the original use of this function)
    or "audit" for a record of an admin performing a sensitive action.
    """
    if not db:
        print(f"No DB connection to log [{type_}]: [{location}] {message} - {details}")
        return

    try:
        doc_ref = db.collection('system_logs').document()
        doc_ref.set({
            'location': location,
            'message': str(message),
            'details': str(details),
            'timestamp': firestore.SERVER_TIMESTAMP,
            'type': type_,
            'actor': actor
        })
    except Exception as e:
        print(f"Failed to write to system_logs: {e}")


def log_admin_action(db, actor: str, action: str, details: str = ""):
    """Convenience wrapper for recording an admin-initiated action as an audit entry."""
    log_error(db, action, f"Performed by {actor}", details, type_="audit", actor=actor)
