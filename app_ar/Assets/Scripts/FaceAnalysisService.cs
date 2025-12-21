using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[System.Serializable]
public class FaceAnalyzeResponse
{
    public bool valid;
    public string reason;
    public string sessionId;
}

public class FaceAnalysisService : MonoBehaviour
{
    [Header("Config")]
    public AppConfig config;

    [Header("AR")]
    [SerializeField] private ARSession arSession;
    [SerializeField] private ARCameraManager arCameraManager;

    private RobotController robot;

    private bool isCameraReady = false;
    private bool isSending = false;

    private string faceSessionId;

    void Start()
    {
        if (arSession != null)
            arSession.enabled = true;

        if (arCameraManager == null)
            Debug.LogError("❌ ARCameraManager not assigned");

        Debug.Log("FaceAnalysisService (AR Camera) STARTED");
    }

    void OnEnable()
    {
        if (arCameraManager != null)
            arCameraManager.frameReceived += OnCameraFrameReceived;
    }

    void OnDisable()
    {
        if (arCameraManager != null)
            arCameraManager.frameReceived -= OnCameraFrameReceived;
    }

    void OnCameraFrameReceived(ARCameraFrameEventArgs args)
    {
        // Chỉ cần nhận được 1 frame là camera sẵn sàng
        isCameraReady = true;
    }

    // ================= ENTRY =================

    public void StartFaceAnalysis(RobotController robotController)
    {
        if (config == null)
        {
            Debug.LogError("❌ AppConfig is not assigned!");
            return;
        }

        robot = robotController;
    }

    // ================= CAPTURE =================

    public void OnCaptureButtonPressed()
    {
        if (!isCameraReady || isSending)
            return;

        StartCoroutine(CaptureAndSend());
    }

    IEnumerator CaptureAndSend()
    {
        isSending = true;

        // đợi frame AR mới nhất
        yield return new WaitForEndOfFrame();

        Texture2D frame = CaptureARCameraFrame();
        if (frame != null)
            yield return SendFrameToBackend(frame);

        isSending = false;
    }

    Texture2D CaptureARCameraFrame()
    {
        if (!arCameraManager.TryAcquireLatestCpuImage(out XRCpuImage image))
        {
            Debug.LogWarning("⚠️ Cannot acquire AR camera image");
            return null;
        }

        using (image)
        {
            var conversionParams = new XRCpuImage.ConversionParams
            {
                inputRect = new RectInt(0, 0, image.width, image.height),
                outputDimensions = new Vector2Int(image.width, image.height),
                outputFormat = TextureFormat.RGB24,
                transformation = XRCpuImage.Transformation.None
            };

            Texture2D texture = new Texture2D(
                image.width,
                image.height,
                TextureFormat.RGB24,
                false
            );

            var rawData = texture.GetRawTextureData<byte>();
            image.Convert(conversionParams, rawData);
            texture.Apply();

            return texture;
        }
    }

    // ================= BACKEND =================

    IEnumerator SendFrameToBackend(Texture2D frame)
    {
        byte[] jpg = frame.EncodeToJPG(85);

        WWWForm form = new WWWForm();
        form.AddBinaryData("file", jpg, "face.jpg", "image/jpeg");

        using (UnityWebRequest req =
               UnityWebRequest.Post(config.FaceAnalyzeBackendUrl, form))
        {
            yield return req.SendWebRequest();

            if (req.result != UnityWebRequest.Result.Success)
            {
                Debug.LogError("❌ Backend error: " + req.error);
                yield break;
            }

            FaceAnalyzeResponse response =
                JsonUtility.FromJson<FaceAnalyzeResponse>(req.downloadHandler.text);

            if (response.valid)
            {
                faceSessionId = response.sessionId;

                Debug.Log("✅ Face session created: " + faceSessionId);

                robot.SetFaceSession(faceSessionId);
                robot.Say("Tuyệt vời! Mình thấy bạn rồi 😊");

                // tự ẩn message sau 3s
                StartCoroutine(HideMessageAfterDelay(3f));

                // ❗ KHÔNG stop camera AR
                StopCaptureOnly();
            }
            else
            {
                HandleInvalidFace(response.reason);
            }
        }
    }

    // ================= CONTROL =================

    void StopCaptureOnly()
    {
        // Chỉ reset trạng thái gửi, KHÔNG đụng camera
        isSending = false;
        Debug.Log("📸 Capture finished (AR camera still running)");
    }

    IEnumerator HideMessageAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);

        if (RobotUI.Instance != null)
            RobotUI.Instance.ShowMessage("");
    }

    void HandleInvalidFace(string reason)
    {
        robot.Say("Mình chưa nhìn rõ. Thử lại nhé.");
    }
}
