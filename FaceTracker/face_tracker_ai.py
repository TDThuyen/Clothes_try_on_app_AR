from fastapi import FastAPI, UploadFile, File
import cv2
import numpy as np
from uniface import RetinaFace, AgeGender

app = FastAPI(title="Face Tracker AI")

# Load models once (important for performance)
detector = RetinaFace()
age_gender = AgeGender()


def preprocess_frame(frame: np.ndarray) -> np.ndarray:
    """
    Adaptive preprocessing for RANDOM images.
    Enhances only when needed.
    """

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    mean_lum = np.mean(gray)
    contrast = np.std(gray)

    processed = frame.copy()

    # 1️⃣ Brightness correction (ONLY if image is dark)
    if mean_lum < 90:
        processed = cv2.convertScaleAbs(processed, alpha=1.0, beta=15)

    # 2️⃣ CLAHE (ONLY if contrast is low)
    if contrast < 70:
        lab = cv2.cvtColor(processed, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)

        clip = 1.6 if contrast > 40 else 2.0
        clahe = cv2.createCLAHE(clipLimit=clip, tileGridSize=(8, 8))
        l = clahe.apply(l)

        processed = cv2.cvtColor(cv2.merge((l, a, b)), cv2.COLOR_LAB2BGR)

    return processed


@app.post("/analyze")
async def analyze_face(file: UploadFile = File(...)):
    # 1️⃣ Validate content type
    if not file.content_type or not file.content_type.startswith("image/"):
        return {"valid": False, "reason": "not_an_image"}

    # 2️⃣ Read bytes
    img_bytes = await file.read()
    if not img_bytes:
        return {"valid": False, "reason": "empty_file"}

    # 3️⃣ Decode image
    img_array = np.frombuffer(img_bytes, np.uint8)
    frame = cv2.imdecode(img_array, cv2.IMREAD_COLOR)

    if frame is None:
        return {"valid": False, "reason": "decode_failed"}

    h, w, _ = frame.shape
    if h < 80 or w < 80:
        return {"valid": False, "reason": "image_too_small"}

    # 4️⃣ Preprocess
    processed_frame = preprocess_frame(frame)

    # 5️⃣ Detect faces
    faces = detector.detect(processed_frame)

    if not faces or len(faces) == 0:
        return {"valid": False, "reason": "no_face"}

    if len(faces) > 1:
        return {"valid": False, "reason": "multiple_faces"}

    # 6️⃣ Validate bbox (FIXED NumPy-safe logic)
    face = faces[0]
    bbox = face.get("bbox")

    if (
        bbox is None
        or not isinstance(bbox, (list, tuple, np.ndarray))
        or len(bbox) != 4
    ):
        return {"valid": False, "reason": "invalid_bbox"}

    x1, y1, x2, y2 = map(int, bbox)

    if x2 <= x1 or y2 <= y1:
        return {"valid": False, "reason": "invalid_bbox"}

    # Clamp bbox to image bounds (extra safety)
    x1 = max(0, min(x1, w - 1))
    x2 = max(0, min(x2, w - 1))
    y1 = max(0, min(y1, h - 1))
    y2 = max(0, min(y2, h - 1))

    # 7️⃣ Predict age & gender (use ORIGINAL frame)
    try:
        gender_idx, age = age_gender.predict(frame, [x1, y1, x2, y2])
    except Exception:
        return {"valid": False, "reason": "prediction_failed"}

    return {
        "valid": True,
        "age": int(age),
        "gender": "Female" if gender_idx == 0 else "Male",
    }


# 🔹 AUTO-START SERVER WITH FIXED PORT
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "face_tracker_ai:app",
        host="0.0.0.0",
        port=8001,
        reload=False,
    )
