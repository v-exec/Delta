using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Texturize : MonoBehaviour {

	private Material mat;
	private Shader shader;

	private WebCamTexture tex;
	private WebCamDevice[] devices;

	private RenderTexture pastFrame;
	private RenderTexture ghost;

	public GameObject texturePlane;
	public Material ghostMat;
	public Texture asciiSampleSmall;
	public Texture asciiSampleLarge;
	public Dropdown cameraDropdown;
	public CanvasGroup UI;
	private bool canvasActive = true;

	[Header("Camera")]
	public int webcam = 0;

	//0 = point
	//1 = ascii
	//2 = dither
	//3 = pixelate
	//4 = blowout

	[Range(0, 4)]
	public int mode = 0;

	[Range(0f, 2f)]
	public float brightness = 1f;

	[Range(0f, 0.9f)]
	public float threshold = 0f;

	[Range(0f, 1.0f)]
	public float smearAmount = 0f;

	[Range(1, 20)]
	public int resolution = 5;

	[Header("Point")]

	[Range(0.01f, 5f)]
	public float pointSize = 0.01f;

	void Start() {
		devices = WebCamTexture.devices;

		//fill dropdown list with webcams
		for (int i = 0; i < devices.Length; i++) {
			cameraDropdown.options.Add (new Dropdown.OptionData() {text=devices[i].name});
		}

		cameraDropdown.value = 1;
		cameraDropdown.value = 0;

		//size plane and camera
		float ratio = (float)tex.width / (float)tex.height;
		texturePlane.transform.localScale = new Vector3(ratio, 1, 1);

		//set up frames
		pastFrame = new RenderTexture (Screen.width, Screen.height, 16);
		ghost = new RenderTexture (Screen.width, Screen.height, 16);

		//material
		mat = new Material(Shader.Find("Texturize")) {hideFlags = HideFlags.DontSave};
	}

	void Update() {
		//toggle UI visibility
		if (Input.GetKeyDown(KeyCode.H)) {
			if (canvasActive) {
				UI.alpha = 0;
				UI.interactable = false;
				canvasActive = false;
			} else {
				UI.alpha = 1;
				UI.interactable = true;
				canvasActive = true;
			}
		}

		//close program
		if (Input.GetKeyDown(KeyCode.Escape)) {
			Application.Quit();
		}
	}

	public void setCamera(int s) {
		webcam = s;

		if (tex) tex.Stop();
		tex = new WebCamTexture(devices[webcam].name);
		texturePlane.GetComponent<Renderer>().material.mainTexture = tex;
		tex.Play();
	}

	public void setMode(float s) {
		mode = (int)s;
	}

	public void setBrightness(float s) {
		brightness = s;
	}

	public void setThreshold(float s) {
		threshold = s;
	}

	public void setSmearAmount(float s) {
		smearAmount = s;
	}

	public void setResolution(float s) {
		resolution = (int)s;
	}

	public void setPointSize(float s) {
		pointSize = s;
	}

	public void OnRenderImage(RenderTexture src, RenderTexture dest) {
		//render ghosting to its own texture set
		ghostMat.SetFloat("_SmearAmount", smearAmount);
		ghostMat.SetTexture("_Past", pastFrame);
		Graphics.Blit(src, ghost, ghostMat);
		Graphics.Blit(ghost, pastFrame);
		
		//communicate parameters
		mat.SetTexture("_Ghost", ghost);
		mat.SetFloat("_Brightness", brightness);
		mat.SetFloat("_Threshold", threshold);
		mat.SetFloat("_SmearAmount", smearAmount);
		mat.SetInt("_Resolution", resolution);
		mat.SetInt("_Mode", mode);
		
		//point
		mat.SetFloat("_PointSize", pointSize);
		
		//ascii
		if (resolution < 10) {
			mat.SetTexture("_ASCIISample", asciiSampleSmall);
			mat.SetInt("_ASCIISampleWidth", 90);
			mat.SetInt("_ASCIIDimensions", 10);
		} else {
			mat.SetTexture("_ASCIISample", asciiSampleLarge);
			mat.SetInt("_ASCIISampleWidth", 180);
			mat.SetInt("_ASCIIDimensions", 20);
		}

		//render to camera
		Graphics.Blit(src, dest, mat);
	}
}