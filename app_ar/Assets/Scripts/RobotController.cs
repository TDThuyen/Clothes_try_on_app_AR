using UnityEngine;

public class RobotController : MonoBehaviour
{
    [Header("Camera Follow Settings")]
    public Camera targetCamera;
    [Range(1f, 20f)]
    public float distance = 5f;
    [Range(-5f, 5f)]
    public float heightOffset = 0f;
    [Range(-5f, 5f)]
    public float horizontalOffset = 0.8f;
    public bool lookAtCamera = true;
    public bool lockVerticalRotation = true;
    [Range(-180f, 180f)]
    public float rotationOffset = 90f;
    [Range(0f, 0.95f)]
    public float positionSmoothing = 0.5f;
    [Range(0f, 0.95f)]
    public float rotationSmoothing = 0.5f;

    [Header("Jump Settings")]
    public float jumpHeight = 0.5f;
    public float jumpDuration = 0.5f;
    public float autoJumpInterval = 10f;

    private Vector3 velocity = Vector3.zero;
    private float lastJumpTime = 0f;
    private bool isJumping = false;
    private float jumpStartTime;
    private bool goingUp = true;
    private float jumpOffsetY = 0f;

    void Start()
    {
        if (targetCamera == null)
        {
            targetCamera = Camera.main;
            if (targetCamera == null)
                Debug.LogError("Camera not assigned!");
        }

        lastJumpTime = Time.time;
    }

    void LateUpdate()
    {
        HandleJump();

        autoJumpInterval = 10;
        if (Time.time - lastJumpTime >= autoJumpInterval)
        {
            StartJump();
            lastJumpTime = Time.time;
        }

        Vector3 targetPosition = targetCamera.transform.position
                                 + targetCamera.transform.forward * distance
                                 + targetCamera.transform.right * horizontalOffset
                                 + Vector3.up * (heightOffset + jumpOffsetY);

        transform.position = Vector3.SmoothDamp(transform.position, targetPosition, ref velocity, positionSmoothing);

        if (lookAtCamera)
        {
            Vector3 dir = targetCamera.transform.position - transform.position;
            if (lockVerticalRotation)
                dir.y = 0;

            if (dir.sqrMagnitude > 0.001f)
            {
                rotationOffset = 90f;
                Quaternion targetRotation = Quaternion.LookRotation(dir) * Quaternion.Euler(0, rotationOffset, 0);
                transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, Time.deltaTime / rotationSmoothing);
            }
        }
    }

    void StartJump()
    {
        if (isJumping) return;
        isJumping = true;
        jumpStartTime = Time.time;
        goingUp = true;
    }

    void HandleJump()
    {
        if (!isJumping)
        {
            jumpOffsetY = 0f;
            return;
        }

        float t = (Time.time - jumpStartTime) / jumpDuration;
        t = Mathf.Clamp01(t);

        jumpHeight = 1;
        if (goingUp)
        {
            jumpOffsetY = Mathf.Lerp(0f, jumpHeight, t);
            if (t >= 1f)
            {
                goingUp = false;
                jumpStartTime = Time.time;
            }
        }
        else
        {
            jumpOffsetY = Mathf.Lerp(jumpHeight, 0f, t);
            if (t >= 1f)
            {
                jumpOffsetY = 0f;
                isJumping = false;
                goingUp = true;
            }
        }
    }
    
    public void Say(string message)
    {
        Debug.Log($"Robot says: {message}");

        // Send to Flutter mobile
    }
}
