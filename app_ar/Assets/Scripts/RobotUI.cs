using UnityEngine;
using TMPro;
using System.Collections;

public class RobotUI : MonoBehaviour
{
    public static RobotUI Instance;

    public TextMeshProUGUI messageText;

    Coroutine hideCoroutine;

    void Awake()
    {
        Instance = this;
        messageText.text = "";
    }

    public void ShowMessage(string msg)
    {
        messageText.text = msg;

        // Nếu đang có coroutine cũ → hủy
        if (hideCoroutine != null)
            StopCoroutine(hideCoroutine);

        // Tự ẩn sau 3 giây
        hideCoroutine = StartCoroutine(HideAfterDelay(3f));
    }

    IEnumerator HideAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);
        messageText.text = "";
        hideCoroutine = null;
    }
}
