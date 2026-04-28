import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function toDisplayColor(color) {
  const palette = {
    natural: '#c7d2da',
    blanco: '#f8fafc',
    negro: '#111827',
    gris: '#6b7280',
    bronce: '#7c5a45',
  };

  return palette[String(color || '').trim().toLowerCase()] || '#c7d2da';
}

function createGroundTexture() {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 512;
  const ctx = canvas.getContext('2d');
  if (!ctx) return null;

  ctx.fillStyle = '#d3d9df';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.strokeStyle = 'rgba(120, 136, 152, 0.35)';
  ctx.lineWidth = 2;

  for (let i = 0; i <= 16; i += 1) {
    const p = i * 32;
    ctx.beginPath();
    ctx.moveTo(p, 0);
    ctx.lineTo(p, canvas.height);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(0, p);
    ctx.lineTo(canvas.width, p);
    ctx.stroke();
  }

  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(8, 8);
  texture.anisotropy = 8;
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}

function addEnvironment(scene) {
  const sky = new THREE.Mesh(
    new THREE.SphereGeometry(70, 48, 32),
    new THREE.MeshBasicMaterial({ color: '#dfeaf6', side: THREE.BackSide })
  );
  scene.add(sky);

  const wallMaterial = new THREE.MeshStandardMaterial({
    color: '#eef2f6',
    roughness: 0.92,
    metalness: 0.02,
  });

  const wall = new THREE.Mesh(new THREE.BoxGeometry(8, 5.8, 0.42), wallMaterial);
  wall.position.set(0, 0.1, -0.36);
  wall.receiveShadow = true;
  scene.add(wall);

  const revealMaterial = new THREE.MeshStandardMaterial({
    color: '#cfd7df',
    roughness: 0.84,
    metalness: 0.03,
  });

  const revealTop = new THREE.Mesh(new THREE.BoxGeometry(2.7, 0.28, 0.5), revealMaterial);
  revealTop.position.set(0, 1.1, -0.02);
  revealTop.castShadow = true;
  revealTop.receiveShadow = true;

  const revealBottom = revealTop.clone();
  revealBottom.position.set(0, -1.1, -0.02);

  const revealSideL = new THREE.Mesh(new THREE.BoxGeometry(0.28, 2.5, 0.5), revealMaterial);
  revealSideL.position.set(-1.2, 0, -0.02);
  revealSideL.castShadow = true;
  revealSideL.receiveShadow = true;

  const revealSideR = revealSideL.clone();
  revealSideR.position.set(1.2, 0, -0.02);

  scene.add(revealTop, revealBottom, revealSideL, revealSideR);

  const groundTexture = createGroundTexture();
  const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(44, 44),
    new THREE.MeshStandardMaterial({
      color: '#d4dbe2',
      map: groundTexture,
      roughness: 0.96,
      metalness: 0.01,
    })
  );
  ground.rotation.x = -Math.PI / 2;
  ground.position.y = -1.45;
  ground.receiveShadow = true;
  scene.add(ground);

  const buildingMatA = new THREE.MeshStandardMaterial({ color: '#d9e1ea', roughness: 0.9, metalness: 0.02 });
  const buildingMatB = new THREE.MeshStandardMaterial({ color: '#c7d2de', roughness: 0.9, metalness: 0.02 });

  const leftBuilding = new THREE.Mesh(new THREE.BoxGeometry(7, 10, 7), buildingMatA);
  leftBuilding.position.set(-9, 2.1, -6.5);
  leftBuilding.castShadow = true;
  leftBuilding.receiveShadow = true;

  const rightBuilding = new THREE.Mesh(new THREE.BoxGeometry(8, 12, 8), buildingMatB);
  rightBuilding.position.set(10.5, 2.8, -8.5);
  rightBuilding.castShadow = true;
  rightBuilding.receiveShadow = true;

  const farBuilding = new THREE.Mesh(new THREE.BoxGeometry(22, 9, 5), buildingMatA);
  farBuilding.position.set(0, 1.8, -17);
  farBuilding.castShadow = true;
  farBuilding.receiveShadow = true;

  scene.add(leftBuilding, rightBuilding, farBuilding);
}

export function WindowViewer3D({ width, height, color }) {
  const mountRef = useRef(null);
  const sceneRef = useRef(null);
  const rendererRef = useRef(null);
  const cameraRef = useRef(null);
  const controlsRef = useRef(null);
  const frameRef = useRef(null);
  const animationRef = useRef(0);

  useEffect(() => {
    const mountNode = mountRef.current;
    if (!mountNode) return undefined;

    const scene = new THREE.Scene();
    scene.background = new THREE.Color('#e3ebf5');
    scene.fog = new THREE.Fog('#dce6f1', 14, 52);

    const camera = new THREE.PerspectiveCamera(42, mountNode.clientWidth / mountNode.clientHeight, 0.1, 120);
    camera.position.set(4.7, 2.2, 7.3);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(mountNode.clientWidth, mountNode.clientHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;
    mountNode.appendChild(renderer.domElement);

    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.minDistance = 3.8;
    controls.maxDistance = 13;
    controls.maxPolarAngle = Math.PI / 2.03;
    controls.target.set(0, 0.2, 0);

    const hemiLight = new THREE.HemisphereLight('#eff6ff', '#a1aab5', 1.15);
    scene.add(hemiLight);

    const sunLight = new THREE.DirectionalLight('#fff8ef', 1.55);
    sunLight.position.set(8, 11, 7);
    sunLight.castShadow = true;
    sunLight.shadow.mapSize.set(2048, 2048);
    sunLight.shadow.camera.near = 0.5;
    sunLight.shadow.camera.far = 60;
    sunLight.shadow.camera.left = -14;
    sunLight.shadow.camera.right = 14;
    sunLight.shadow.camera.top = 14;
    sunLight.shadow.camera.bottom = -14;
    sunLight.shadow.bias = -0.00012;
    scene.add(sunLight);

    const fillLight = new THREE.DirectionalLight('#dce8ff', 0.7);
    fillLight.position.set(-8, 4.5, -7);
    scene.add(fillLight);

    addEnvironment(scene);

    sceneRef.current = scene;
    rendererRef.current = renderer;
    cameraRef.current = camera;
    controlsRef.current = controls;

    const onResize = () => {
      if (!mountRef.current || !rendererRef.current || !cameraRef.current) return;
      const widthValue = mountRef.current.clientWidth;
      const heightValue = mountRef.current.clientHeight;
      rendererRef.current.setSize(widthValue, heightValue);
      cameraRef.current.aspect = widthValue / heightValue;
      cameraRef.current.updateProjectionMatrix();
    };

    window.addEventListener('resize', onResize);

    const renderLoop = () => {
      controls.update();
      renderer.render(scene, camera);
      animationRef.current = window.requestAnimationFrame(renderLoop);
    };
    renderLoop();

    return () => {
      window.cancelAnimationFrame(animationRef.current);
      window.removeEventListener('resize', onResize);
      controls.dispose();
      renderer.dispose();
      mountNode.removeChild(renderer.domElement);
    };
  }, []);

  useEffect(() => {
    const scene = sceneRef.current;
    if (!scene) return;

    if (frameRef.current) {
      scene.remove(frameRef.current);
    }

    const widthScale = clamp((Number(width) || 160) / 100, 0.9, 3.2);
    const heightScale = clamp((Number(height) || 120) / 100, 0.8, 2.8);
    const depth = 0.16;
    const frameThickness = 0.12;
    const frameColor = new THREE.Color(toDisplayColor(color));

    const group = new THREE.Group();

    const frameMaterial = new THREE.MeshStandardMaterial({
      color: frameColor,
      roughness: 0.4,
      metalness: 0.36,
    });

    const glassMaterial = new THREE.MeshPhysicalMaterial({
      color: '#cfe3fb',
      metalness: 0.03,
      roughness: 0.03,
      transmission: 0.82,
      transparent: true,
      opacity: 0.42,
      thickness: 0.12,
      ior: 1.45,
      reflectivity: 0.75,
      clearcoat: 0.65,
      clearcoatRoughness: 0.08,
    });

    const leftFrame = new THREE.Mesh(new THREE.BoxGeometry(frameThickness, heightScale, depth), frameMaterial);
    leftFrame.position.set(-widthScale / 2, 0, 0);

    const rightFrame = leftFrame.clone();
    rightFrame.position.set(widthScale / 2, 0, 0);

    const topFrame = new THREE.Mesh(new THREE.BoxGeometry(widthScale + frameThickness, frameThickness, depth), frameMaterial);
    topFrame.position.set(0, heightScale / 2, 0);

    const bottomFrame = topFrame.clone();
    bottomFrame.position.set(0, -heightScale / 2, 0);

    const centerRail = new THREE.Mesh(new THREE.BoxGeometry(frameThickness * 0.75, heightScale - 0.1, depth * 0.9), frameMaterial);
    centerRail.position.set(0, 0, 0.02);

    const leftGlass = new THREE.Mesh(new THREE.BoxGeometry(widthScale / 2 - 0.1, heightScale - 0.14, 0.04), glassMaterial);
    leftGlass.position.set(-widthScale / 4, 0, 0);

    const rightGlass = leftGlass.clone();
    rightGlass.position.set(widthScale / 4, 0, 0.02);

    const sill = new THREE.Mesh(
      new THREE.BoxGeometry(widthScale + 0.45, 0.12, 0.5),
      new THREE.MeshStandardMaterial({ color: '#4b5563', roughness: 0.86, metalness: 0.05 })
    );
    sill.position.set(0, -heightScale / 2 - 0.16, 0.02);

    const frameParts = [leftFrame, rightFrame, topFrame, bottomFrame, centerRail, leftGlass, rightGlass, sill];
    frameParts.forEach((part) => {
      part.castShadow = true;
      part.receiveShadow = true;
    });

    group.add(...frameParts);
    group.position.set(0, 0.05, 0.24);
    frameRef.current = group;
    scene.add(group);
  }, [width, height, color]);

  return <div className="viewer-canvas" ref={mountRef} />;
}
