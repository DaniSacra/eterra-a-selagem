// QA tool (outside the game): end-to-end input latency on the real GPU, without a camera.
// Sends a key (or a left click) to the game window by SendInput, stamps the QueryPerformanceCounter, then polls the
// composed desktop (GDI BitBlt of a region of the window, what DWM shows) until the region changes; prints the ms.
//   latency.exe shot <out.bmp>                       window client area to a BMP (to pick the region)
//   latency.exe run <key> <trials> <x> <y> <w> <h>   key: space | d | click ; region in client pixels
// Not measured: USB polling, the monitor's scan-out and pixel response (needs a high-speed camera).
using System; using System.Diagnostics; using System.Runtime.InteropServices; using System.Threading;
using System.Drawing; using System.Drawing.Imaging; using System.Linq;
class L {
 [DllImport("user32.dll")] static extern bool SetProcessDPIAware();
 [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] static extern bool GetClientRect(IntPtr h, out RECT r);
 [DllImport("user32.dll")] static extern bool ClientToScreen(IntPtr h, ref POINT p);
 [DllImport("user32.dll")] static extern IntPtr GetDC(IntPtr h);
 [DllImport("user32.dll")] static extern int ReleaseDC(IntPtr h, IntPtr dc);
 [DllImport("user32.dll")] static extern bool SetCursorPos(int x, int y);
 [DllImport("user32.dll")] static extern bool GetCursorPos(out POINT p);
 [DllImport("user32.dll")] static extern uint SendInput(uint n, INPUT[] i, int size);
 [DllImport("user32.dll")] static extern IntPtr FindWindow(string c, string t);
 [DllImport("user32.dll")] static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
 [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
 [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] static extern int GetWindowTextLength(IntPtr h);
 delegate bool EnumProc(IntPtr h, IntPtr l);
 [DllImport("gdi32.dll")] static extern IntPtr CreateCompatibleDC(IntPtr dc);
 [DllImport("gdi32.dll")] static extern IntPtr CreateDIBSection(IntPtr dc, ref BITMAPINFO bi, uint u, out IntPtr bits, IntPtr s, uint o);
 [DllImport("gdi32.dll")] static extern IntPtr SelectObject(IntPtr dc, IntPtr o);
 [DllImport("gdi32.dll")] static extern bool BitBlt(IntPtr d, int x, int y, int w, int h, IntPtr s, int sx, int sy, uint rop);
 [DllImport("gdi32.dll")] static extern bool GdiFlush();
 [DllImport("user32.dll")] static extern bool EnumDisplaySettings(string d, int m, ref DEVMODE dm);
 [StructLayout(LayoutKind.Sequential)] struct RECT { public int l, t, r, b; }
 [StructLayout(LayoutKind.Sequential)] struct POINT { public int x, y; }
 [StructLayout(LayoutKind.Sequential)] struct BITMAPINFO { public int size, w, h; public short planes, bits; public int comp, img, xp, yp, used, imp; }
 [StructLayout(LayoutKind.Sequential)] struct KEYBDINPUT { public ushort vk, scan; public uint flags, time; public IntPtr extra; }
 [StructLayout(LayoutKind.Sequential)] struct MOUSEINPUT { public int dx, dy; public uint data, flags, time; public IntPtr extra; }
 [StructLayout(LayoutKind.Explicit)] struct UNION { [FieldOffset(0)] public KEYBDINPUT k; [FieldOffset(0)] public MOUSEINPUT m; }
 [StructLayout(LayoutKind.Sequential)] struct INPUT { public uint type; public UNION u; }
 [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)] struct DEVMODE {
  [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dn; public short sv, dv, size, extra; public int fields;
  public int px, py, ori, fo; public short color, duplex, yres, tt, collate;
  [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string fn; public short lp; public int bpp, pw, ph, flags, freq; }

 static IntPtr win; static int cx, cy;
 static IntPtr FindGodot() {
  IntPtr found = IntPtr.Zero;
  var ids = Process.GetProcesses().Where(p => p.ProcessName.StartsWith("Godot_v4")).Select(p => p.Id).ToArray();
  EnumWindows((h, l) => { int pid; GetWindowThreadProcessId(h, out pid);
   if (ids.Contains(pid) && IsWindowVisible(h) && GetWindowTextLength(h) > 0) { found = h; return false; } return true; }, IntPtr.Zero);
  return found;
 }
 static void Send(string key, bool down) {
  var i = new INPUT[1];
  if (key == "click") { i[0].type = 0; i[0].u.m.flags = down ? 0x0002u : 0x0004u; }
  else { i[0].type = 1; i[0].u.k.scan = (ushort)(key == "space" ? 0x39 : key == "d" ? 0x20 : key == "a" ? 0x1E : 0x1F);
   i[0].u.k.flags = 0x0008u | (down ? 0u : 0x0002u); }
  SendInput(1, i, Marshal.SizeOf(typeof(INPUT)));
 }
 static int Main(string[] a) {
  SetProcessDPIAware();
  for (int k = 0; k < 100 && (win = FindGodot()) == IntPtr.Zero; k++) Thread.Sleep(200);
  if (win == IntPtr.Zero) { Console.WriteLine("no game window"); return 1; }
  RECT rc; GetClientRect(win, out rc); POINT o = new POINT(); ClientToScreen(win, ref o); cx = o.x; cy = o.y;
  var dm = new DEVMODE(); dm.size = (short)Marshal.SizeOf(typeof(DEVMODE)); EnumDisplaySettings(null, -1, ref dm);
  Console.WriteLine("window client {0}x{1} at {2},{3}; display {4} Hz", rc.r, rc.b, cx, cy, dm.freq);
  if (a[0] == "shot") {
   SetForegroundWindow(win); Thread.Sleep(300);
   using (var b = new Bitmap(rc.r, rc.b)) { using (var g = Graphics.FromImage(b)) g.CopyFromScreen(cx, cy, 0, 0, b.Size); b.Save(a[1], ImageFormat.Bmp); }
   return 0;
  }
  string key = a[1]; int trials = int.Parse(a[2]); int x = int.Parse(a[3]), y = int.Parse(a[4]), w = int.Parse(a[5]), h = int.Parse(a[6]);
  IntPtr sdc = GetDC(IntPtr.Zero), mdc = CreateCompatibleDC(sdc);
  var bi = new BITMAPINFO { size = 40, w = w, h = -h, planes = 1, bits = 32 }; IntPtr bits;
  SelectObject(mdc, CreateDIBSection(mdc, ref bi, 0, out bits, IntPtr.Zero, 0));
  int n = w * h; var cur = new int[n]; var refp = new int[n];
  Func<int[], long> grab = (dst) => { BitBlt(mdc, 0, 0, w, h, sdc, cx + x, cy + y, 0x00CC0020); GdiFlush(); Marshal.Copy(bits, dst, 0, n); return Stopwatch.GetTimestamp(); };
  // how many pixels changed clearly (sum of the three channels moved by more than 60)
  Func<int[], int[], double> diff = (p, q) => { int c = 0; for (int i = 0; i < n; i++) { int u = p[i], v = q[i];
   int s = Math.Abs((u & 255) - (v & 255)) + Math.Abs(((u >> 8) & 255) - ((v >> 8) & 255)) + Math.Abs(((u >> 16) & 255) - ((v >> 16) & 255));
   if (s > 60) c++; } return c; };
  double f = Stopwatch.Frequency / 1000.0; var rnd = new Random(7); var res = new System.Collections.Generic.List<double>();
  POINT keep; GetCursorPos(out keep);
  for (int t = 0; t < trials; t++) {
   SetForegroundWindow(win); Thread.Sleep(600 + rnd.Next(400));
   if (GetForegroundWindow() != win) { Console.WriteLine("trial {0}: game not in front, skipped", t); continue; }
   if (key == "click") SetCursorPos(cx + rc.r / 2 + 200, cy + rc.b / 2);
   // the idle noise of the region for 0.5 s (the hero breathing, fires, mist): the change must be well above it
   // the idle change over 60 ms (as long as the wait we look for): each poll against the one 9 polls before
   var ring = new int[9][]; for (int k = 0; k < 9; k++) ring[k] = new int[n];
   double noise = 0; long end = Stopwatch.GetTimestamp() + (long)(700 * f); long polls = 0;
   while (Stopwatch.GetTimestamp() < end) { var slot = ring[polls % 9]; if (polls >= 9) { grab(cur); noise = Math.Max(noise, diff(cur, slot)); Array.Copy(cur, slot, n); } else grab(slot); polls++; }
   double thr = Math.Max(40.0, noise * 1.3 + 40.0);
   var seq = new System.Text.StringBuilder();
   grab(refp);
   long t0 = Stopwatch.GetTimestamp(); Send(key, true);
   double lat = -1, d = 0; long tl = t0, maxt = t0 + (long)(400 * f); polls = 0;
   while (true) { long tp = grab(cur); polls++; d = diff(cur, refp); seq.AppendFormat("{0:F0}:{1:F0} ", (tp - t0) / f, d); if (d > thr) { lat = (tp - t0) / f; break; } if (tp > maxt) break; tl = tp; }
   double gap = polls > 0 ? (Stopwatch.GetTimestamp() - t0) / f / polls : 0;
   Thread.Sleep(key == "d" ? 250 : 60); Send(key, false);
   Console.WriteLine("trial {0}: {1:F1} ms (previous poll {2:F1} ms; diff {3:F1} > {4:F1}, idle max {5:F1}; poll {6:F2} ms)", t, lat, (tl - t0) / f, d, thr, noise, gap);
   if (t < 2) Console.WriteLine("   polls ms:changed " + seq);
   if (lat >= 0) res.Add(lat);
   Thread.Sleep(700);
   // back near the start, facing right again: the walk right is undone by a walk left (same time), the dodge
   // (5.6 m) by 0.83 s of walking left, the lunge of a swing (about 1 m) by 0.15 s
   int back = key == "d" ? 250 : key == "space" ? 830 : 150;
   Send("a", true); Thread.Sleep(back); Send("a", false); Thread.Sleep(80);
   Send("d", true); Thread.Sleep(20); Send("d", false); Thread.Sleep(400);
  }
  SetCursorPos(keep.x, keep.y);
  if (res.Count > 0) { res.Sort(); Console.WriteLine("RESULT key={0} n={1} min={2:F1} median={3:F1} mean={4:F1} max={5:F1} ms",
   key, res.Count, res[0], res[res.Count / 2], res.Average(), res[res.Count - 1]); }
  return 0;
 }
}
