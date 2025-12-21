using UnityEngine;

[CreateAssetMenu(
    fileName = "AppConfig",
    menuName = "Config/AppConfig",
    order = 1
)]
public class AppConfig : ScriptableObject
{
    [Header("Backend API")]
    [Tooltip("Base URL of backend API (NO trailing slash)")]
    public string apiBaseUrl;
    // Example: https://api.yourapp.com

    [Tooltip("Face analyze endpoint (backend route)")]
    public string faceAnalyzeEndpoint = "api/chatbot/face-analyze";

    [Header("Camera / AI Timing")]
    [Tooltip("Seconds to wait before first capture")]
    public float initialCaptureDelay = 3f;

    [Tooltip("Seconds between retries when face is invalid")]
    public float retryDelay = 3f;

    [Header("Debug")]
    public bool enableDebugLogs = true;

    // ✅ BACKEND FACE ANALYZE URL
    public string FaceAnalyzeBackendUrl
    {
        get
        {
            if (string.IsNullOrEmpty(apiBaseUrl))
                return "";

            return apiBaseUrl.TrimEnd('/') + faceAnalyzeEndpoint;
        }
    }
}
