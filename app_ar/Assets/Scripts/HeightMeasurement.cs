using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.Events;
using UnityEngine.XR.ARSubsystems;

public class HeightMeasurementController : MonoBehaviour
{
   [Header("Dependencies")]
   [SerializeField] private ARHumanBodyManager bodyManager;
   [SerializeField] private RobotController robot;
  
   [Header("Settings")]
   [SerializeField] private float measurementCooldown = 2f;
   [SerializeField] private float minConfidenceThreshold = 0.5f;
   [SerializeField] private bool allowRemeasurement = false;
  
   [Header("Events")]
   public UnityEvent<float> onHeightMeasured;
   public UnityEvent onTrackingLost;
   public UnityEvent onPartialBodyDetected;

   private bool measurementDone = false;
   private float lastFeedbackTime = 0f;
   private ARHumanBody currentTrackedBody;
  
   // Joint indices theo AR Foundation standard
   private const int HEAD_INDEX = (int)JointIndices3D.Head;
   private const int LEFT_FOOT_INDEX = (int)JointIndices3D.LeftFoot;
   private const int RIGHT_FOOT_INDEX = (int)JointIndices3D.RightFoot;


   void Awake() {
       if (bodyManager == null) {
           bodyManager = FindObjectOfType<ARHumanBodyManager>();
       }
   }
  
   void Start()
   {
       Debug.Log($"Body Tracking Supported: {bodyManager.subsystem?.subsystemDescriptor.supportsHumanBody3D}");
       Debug.Log($"Subsystem: {bodyManager.subsystem}, Running: {bodyManager.subsystem?.running}");
   }


   private void OnEnable()
   {
       if (bodyManager != null)
       {
           bodyManager.humanBodiesChanged += OnHumanBodiesChanged;
       }
   }


   private void OnDisable()
   {
       if (bodyManager != null)
       {
           bodyManager.humanBodiesChanged -= OnHumanBodiesChanged;
       }
   }


   private void OnHumanBodiesChanged(ARHumanBodiesChangedEventArgs args)
   {
       if (measurementDone && !allowRemeasurement) return;


       // Update current tracked body
       if (args.updated.Count > 0)
       {
           currentTrackedBody = args.updated[0];
       }
       else if (args.added.Count > 0)
       {
           currentTrackedBody = args.added[0];
       }


       // Handle removed bodies
       if (args.removed.Count > 0 && currentTrackedBody != null)
       {
           if (args.removed.Contains(currentTrackedBody))
           {
               currentTrackedBody = null;
               onTrackingLost?.Invoke();
           }
       }
   }


   void Update()
   {
       if (measurementDone && !allowRemeasurement) return;
      
       // Throttle feedback messages
       if (Time.time - lastFeedbackTime < measurementCooldown) return;


       ProcessMeasurement();
   }


   private void ProcessMeasurement()
   {
       // Check if any body is being tracked
       if (currentTrackedBody == null || bodyManager.trackables.count == 0)
       {
           ProvideFeedback("Không thấy bạn rồi, bước vào camera nhé!");
           return;
       }


       // Validate body tracking quality
       BodyTrackingStatus status = ValidateBodyTracking(currentTrackedBody);


       switch (status)
       {
           case BodyTrackingStatus.FullBodyTracked:
               PerformMeasurement(currentTrackedBody);
               break;
              
           case BodyTrackingStatus.PartialBodyTracked:
               ProvideFeedback("Hãy lùi xa thêm một chút để mình thấy toàn thân nhé!");
               onPartialBodyDetected?.Invoke();
               break;
              
           case BodyTrackingStatus.LowConfidence:
               ProvideFeedback("Đứng yên một chút để mình đo chính xác hơn nhé!");
               break;
              
           case BodyTrackingStatus.InvalidData:
               ProvideFeedback("Dữ liệu chưa ổn định, vui lòng đợi một chút!");
               break;
       }
   }


   private BodyTrackingStatus ValidateBodyTracking(ARHumanBody body)
   {
       if (body == null)
           return BodyTrackingStatus.InvalidData;


       if (body.trackingState != TrackingState.Tracking)
           return BodyTrackingStatus.LowConfidence;


       var joints = body.joints;
      
       if (!joints.IsCreated || joints.Length == 0)
           return BodyTrackingStatus.InvalidData;


       // Check if required joints are tracked
       bool headTracked = IsJointTracked(joints, HEAD_INDEX);
       bool leftFootTracked = IsJointTracked(joints, LEFT_FOOT_INDEX);
       bool rightFootTracked = IsJointTracked(joints, RIGHT_FOOT_INDEX);


       if (!headTracked || !leftFootTracked || !rightFootTracked)
           return BodyTrackingStatus.PartialBodyTracked;


       // Check tracking confidence
       if (body.trackingState != UnityEngine.XR.ARSubsystems.TrackingState.Tracking)
           return BodyTrackingStatus.LowConfidence;


       return BodyTrackingStatus.FullBodyTracked;
   }


   private bool IsJointTracked(Unity.Collections.NativeArray<XRHumanBodyJoint> joints, int index)
   {
       if (index < 0 || index >= joints.Length)
           return false;


       return joints[index].tracked;
   }


   private void PerformMeasurement(ARHumanBody body)
   {
       float height = CalculateHeight(body);


       if (height <= 0f || height > 3f) // Sanity check (0-3 meters)
       {
           ProvideFeedback("Đo không chính xác, thử lại nhé!");
           return;
       }


       measurementDone = true;


       // Celebrate and announce result
       if (robot != null)
       {
           robot.Say($"Yay! Chiều cao của bạn là {height * 100f:0.0} cm 🎉");
       }


       onHeightMeasured?.Invoke(height);
      
       Debug.Log($"Height measured: {height * 100f:0.0} cm");
   }


   private float CalculateHeight(ARHumanBody body)
   {
       var joints = body.joints;


       if (!joints.IsCreated || joints.Length == 0)
           return 0f;


       // Get joint positions
       Vector3 headPos = joints[HEAD_INDEX].anchorPose.position;
       Vector3 leftFootPos = joints[LEFT_FOOT_INDEX].anchorPose.position;
       Vector3 rightFootPos = joints[RIGHT_FOOT_INDEX].anchorPose.position;


       // Calculate average foot position for more accuracy
       Vector3 footAverage = (leftFootPos + rightFootPos) / 2f;


       // Calculate height as vertical distance
       float height = Vector3.Distance(headPos, footAverage);


       return height;
   }


   private void ProvideFeedback(string message)
   {
       lastFeedbackTime = Time.time;
      
       if (robot != null)
       {
           robot.Say(message);
       }
      
       Debug.Log($"Feedback: {message}");
   }


   /// <summary>
   /// Reset measurement to allow re-measuring
   /// </summary>
   public void ResetMeasurement()
   {
       measurementDone = false;
       currentTrackedBody = null;
       Debug.Log("Measurement reset");
   }


   /// <summary>
   /// Get the last measured height
   /// </summary>
   public bool TryGetLastMeasurement(out float height)
   {
       height = 0f;
      
       if (!measurementDone || currentTrackedBody == null)
           return false;


       height = CalculateHeight(currentTrackedBody);
       return height > 0f;
   }


   private enum BodyTrackingStatus
   {
       FullBodyTracked,
       PartialBodyTracked,
       LowConfidence,
       InvalidData
   }


   /// <summary>
   /// Standard joint indices for AR Foundation 3D body tracking
   /// </summary>
   private enum JointIndices3D
   {
       Head = 10,
       LeftFoot = 25,
       RightFoot = 26
   }
}