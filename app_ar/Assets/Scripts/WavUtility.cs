using UnityEngine;
using System.IO;
using System.Text;

public static class WavUtility
{
    public static byte[] FromAudioClip(AudioClip clip)
    {
        float[] samples = new float[clip.samples];
        clip.GetData(samples, 0);

        short[] pcm = new short[samples.Length];
        byte[] bytes = new byte[samples.Length * 2];

        for (int i = 0; i < samples.Length; i++)
        {
            pcm[i] = (short)(samples[i] * short.MaxValue);
            byte[] b = System.BitConverter.GetBytes(pcm[i]);
            b.CopyTo(bytes, i * 2);
        }

        using (MemoryStream stream = new MemoryStream())
        {
            WriteWavHeader(stream, clip, bytes.Length);
            stream.Write(bytes, 0, bytes.Length);
            return stream.ToArray();
        }
    }

    static void WriteWavHeader(Stream stream, AudioClip clip, int dataLength)
    {
        int hz = clip.frequency;
        int channels = clip.channels;

        stream.Write(Encoding.ASCII.GetBytes("RIFF"), 0, 4);
        stream.Write(System.BitConverter.GetBytes(36 + dataLength), 0, 4);
        stream.Write(Encoding.ASCII.GetBytes("WAVE"), 0, 4);
        stream.Write(Encoding.ASCII.GetBytes("fmt "), 0, 4);
        stream.Write(System.BitConverter.GetBytes(16), 0, 4);
        stream.Write(System.BitConverter.GetBytes((short)1), 0, 2);
        stream.Write(System.BitConverter.GetBytes((short)channels), 0, 2);
        stream.Write(System.BitConverter.GetBytes(hz), 0, 4);
        stream.Write(System.BitConverter.GetBytes(hz * channels * 2), 0, 4);
        stream.Write(System.BitConverter.GetBytes((short)(channels * 2)), 0, 2);
        stream.Write(System.BitConverter.GetBytes((short)16), 0, 2);
        stream.Write(Encoding.ASCII.GetBytes("data"), 0, 4);
        stream.Write(System.BitConverter.GetBytes(dataLength), 0, 4);
    }
}
