import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function normalizeToken(value) {
  return String(value || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function toDisplayColor(color) {
  const key = normalizeToken(color);
  if (!key) return '#c7d2da';

  if (key.includes('negro') || key.includes('antracita') || key.includes('grafito')) return '#1f2937';
  if (key.includes('blanco') || key.includes('hueso') || key.includes('marfil')) return '#f8fafc';
  if (key.includes('gris') || key.includes('plata') || key.includes('silver')) return '#7b8794';
  if (key.includes('bronce') || key.includes('cafe') || key.includes('madera') || key.includes('nogal')) return '#7c5a45';
  if (key.includes('champagne') || key.includes('oro') || key.includes('dorado') || key.includes('beige')) return '#b8a37d';
  if (key.includes('azul')) return '#4a6b95';
  if (key.includes('verde')) return '#4b6b5e';

  return '#c7d2da';
}

function createTileTexture() {
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

function createWoodTexture() {
  const canvas = document.createElement('canvas');
  canvas.width = 1024;
  canvas.height = 512;
  const ctx = canvas.getContext('2d');
  if (!ctx) return null;

  const gradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
  gradient.addColorStop(0, '#d8c3a6');
  gradient.addColorStop(0.5, '#cdb392');
  gradient.addColorStop(1, '#dec7ad');
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  for (let i = 0; i < 64; i += 1) {
    const y = Math.random() * canvas.height;
    const h = 2 + Math.random() * 5;
    ctx.fillStyle = `rgba(110, 82, 52, ${0.08 + Math.random() * 0.08})`;
    ctx.fillRect(0, y, canvas.width, h);
  }

  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(6, 4);
  texture.anisotropy = 8;
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}

function createInstallationGroup(widthScale, heightScale, color) {
  const group = new THREE.Group();

  const frameColor = new THREE.Color(toDisplayColor(color));
  const wallWidth = clamp(widthScale + 4.8, 6.2, 9.4);
  const wallHeight = clamp(heightScale + 2.6, 4.3, 6.4);
  const openingWidth = widthScale + 0.55;
  const openingHeight = heightScale + 0.42;
  const wallDepth = 0.36;

  const sideWidth = (wallWidth - openingWidth) / 2;
  const topHeight = (wallHeight - openingHeight) / 2;

  const wallMaterial = new THREE.MeshStandardMaterial({
    color: '#edf1f5',
    roughness: 0.93,
    metalness: 0.01,
  });

  const revealMaterial = new THREE.MeshStandardMaterial({
    color: '#c8d2dd',
    roughness: 0.86,
    metalness: 0.03,
  });

  const frameMaterial = new THREE.MeshStandardMaterial({
    color: frameColor,
    roughness: 0.34,
    metalness: 0.44,
  });

  const glassMaterial = new THREE.MeshPhysicalMaterial({
    color: '#e4f0ff',
    roughness: 0.015,
    metalness: 0.03,
    transmission: 0.92,
    transparent: true,
    opacity: 0.33,
    thickness: 0.14,
    ior: 1.48,
    reflectivity: 0.9,
    clearcoat: 0.85,
    clearcoatRoughness: 0.04,
  });

  const wallLeft = new THREE.Mesh(new THREE.BoxGeometry(sideWidth, wallHeight, wallDepth), wallMaterial);
  wallLeft.position.set(-(openingWidth / 2 + sideWidth / 2), 0, -0.38);

  const wallRight = wallLeft.clone();
  wallRight.position.x = -wallLeft.position.x;

  const wallTop = new THREE.Mesh(new THREE.BoxGeometry(openingWidth, topHeight, wallDepth), wallMaterial);
  wallTop.position.set(0, openingHeight / 2 + topHeight / 2, -0.38);

  const wallBottom = wallTop.clone();
  wallBottom.position.y = -(openingHeight / 2 + topHeight / 2);

  const revealDepth = 0.54;
  const revealThickness = 0.15;
  const revealTop = new THREE.Mesh(new THREE.BoxGeometry(openingWidth + revealThickness * 2, revealThickness, revealDepth), revealMaterial);
  revealTop.position.set(0, openingHeight / 2, -0.14);

  const revealBottom = revealTop.clone();
  revealBottom.position.y = -openingHeight / 2;

  const revealSideL = new THREE.Mesh(new THREE.BoxGeometry(revealThickness, openingHeight, revealDepth), revealMaterial);
  revealSideL.position.set(-openingWidth / 2, 0, -0.14);

  const revealSideR = revealSideL.clone();
  revealSideR.position.x = openingWidth / 2;

  const frameThickness = 0.12;
  const frameDepth = 0.17;
  const leftFrame = new THREE.Mesh(new THREE.BoxGeometry(frameThickness, heightScale, frameDepth), frameMaterial);
  leftFrame.position.set(-widthScale / 2, 0, 0.2);

  const rightFrame = leftFrame.clone();
  rightFrame.position.x = widthScale / 2;

  const topFrame = new THREE.Mesh(new THREE.BoxGeometry(widthScale + frameThickness, frameThickness, frameDepth), frameMaterial);
  topFrame.position.set(0, heightScale / 2, 0.2);

  const bottomFrame = topFrame.clone();
  bottomFrame.position.y = -heightScale / 2;

  const centerRail = new THREE.Mesh(new THREE.BoxGeometry(frameThickness * 0.82, heightScale - 0.1, frameDepth * 0.95), frameMaterial);
  centerRail.position.set(0, 0, 0.21);

  const leafOffset = widthScale / 4;
  const glassWidth = widthScale / 2 - 0.1;
  const glassHeight = heightScale - 0.14;
  const leftGlass = new THREE.Mesh(new THREE.BoxGeometry(glassWidth, glassHeight, 0.05), glassMaterial);
  leftGlass.position.set(-leafOffset, 0, 0.2);

  const rightGlass = leftGlass.clone();
  rightGlass.position.set(leafOffset, 0, 0.23);

  const railBase = new THREE.Mesh(
    new THREE.BoxGeometry(widthScale + 0.5, 0.12, 0.5),
    new THREE.MeshStandardMaterial({ color: '#5b6472', roughness: 0.84, metalness: 0.06 })
  );
  railBase.position.set(0, -heightScale / 2 - 0.16, 0.18);

  const handleMaterial = new THREE.MeshStandardMaterial({ color: '#a8b4c0', roughness: 0.25, metalness: 0.72 });
  const handleL = new THREE.Mesh(new THREE.BoxGeometry(0.03, 0.24, 0.03), handleMaterial);
  handleL.position.set(-0.05, 0.03, 0.26);
  const handleR = handleL.clone();
  handleR.position.x = 0.05;

  const parts = [
    wallLeft,
    wallRight,
    wallTop,
    wallBottom,
    revealTop,
    revealBottom,
    revealSideL,
    revealSideR,
    leftFrame,
    rightFrame,
    topFrame,
    bottomFrame,
    centerRail,
    leftGlass,
    rightGlass,
    railBase,
    handleL,
    handleR,
  ];

  parts.forEach((part) => {
    part.castShadow = true;
    part.receiveShadow = true;
    group.add(part);
  });

  group.position.y = 0.08;
  return group;
}

function addEnvironment(scene) {
  const sky = new THREE.Mesh(
    new THREE.SphereGeometry(70, 48, 32),
    new THREE.MeshBasicMaterial({ color: '#d5e8fb', side: THREE.BackSide })
  );
  scene.add(sky);

  const woodTexture = createWoodTexture();
  const interiorFloor = new THREE.Mesh(
    new THREE.PlaneGeometry(16, 12),
    new THREE.MeshStandardMaterial({
      color: '#d6c0a4',
      map: woodTexture,
      roughness: 0.74,
      metalness: 0.03,
    })
  );
  interiorFloor.rotation.x = -Math.PI / 2;
  interiorFloor.position.set(0, -1.42, 3.1);
  interiorFloor.receiveShadow = true;
  scene.add(interiorFloor);

  const rightWall = new THREE.Mesh(
    new THREE.PlaneGeometry(10, 6),
    new THREE.MeshStandardMaterial({ color: '#f4f1ec', roughness: 0.92, metalness: 0.02 })
  );
  rightWall.position.set(4.3, 0.3, 2.2);
  rightWall.rotation.y = -Math.PI / 2;
  rightWall.receiveShadow = true;
  scene.add(rightWall);

  const ceiling = new THREE.Mesh(
    new THREE.PlaneGeometry(16, 10),
    new THREE.MeshStandardMaterial({ color: '#f7f5f2', roughness: 0.96, metalness: 0.01 })
  );
  ceiling.position.set(0, 2.85, 1.8);
  ceiling.rotation.x = Math.PI / 2;
  ceiling.receiveShadow = true;
  scene.add(ceiling);

  const tileTexture = createTileTexture();
  const exteriorDeck = new THREE.Mesh(
    new THREE.PlaneGeometry(14, 10),
    new THREE.MeshStandardMaterial({ color: '#d6dde5', map: tileTexture, roughness: 0.95, metalness: 0.02 })
  );
  exteriorDeck.rotation.x = -Math.PI / 2;
  exteriorDeck.position.set(0, -1.44, -2.2);
  exteriorDeck.receiveShadow = true;
  scene.add(exteriorDeck);

  const grass = new THREE.Mesh(
    new THREE.PlaneGeometry(44, 30),
    new THREE.MeshStandardMaterial({ color: '#88a574', roughness: 0.98, metalness: 0 })
  );
  grass.rotation.x = -Math.PI / 2;
  grass.position.set(0, -1.48, -12);
  grass.receiveShadow = true;
  scene.add(grass);

  const treeTrunkMat = new THREE.MeshStandardMaterial({ color: '#7b5e46', roughness: 0.9, metalness: 0.01 });
  const treeLeafMat = new THREE.MeshStandardMaterial({ color: '#5f8750', roughness: 0.95, metalness: 0.01 });

  const trees = [
    { x: -5.8, z: -9.5, h: 2.2, c: 1.5 },
    { x: -2.4, z: -11.2, h: 2.6, c: 1.7 },
    { x: 4.8, z: -10.8, h: 2.4, c: 1.6 },
  ];

  trees.forEach((tree) => {
    const trunk = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.16, tree.h, 10), treeTrunkMat);
    trunk.position.set(tree.x, -1.45 + tree.h / 2, tree.z);
    trunk.castShadow = true;
    trunk.receiveShadow = true;

    const crown = new THREE.Mesh(new THREE.SphereGeometry(tree.c, 16, 16), treeLeafMat);
    crown.position.set(tree.x, trunk.position.y + tree.h / 2 + tree.c * 0.45, tree.z);
    crown.castShadow = true;
    crown.receiveShadow = true;

    scene.add(trunk, crown);
  });

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

function disposeGroup(group) {
  if (!group) return;
  group.traverse((node) => {
    if (node.geometry) node.geometry.dispose();
    if (Array.isArray(node.material)) {
      node.material.forEach((material) => material.dispose());
    } else if (node.material) {
      node.material.dispose();
    }
  });
}

function getEnvironmentPreset(environment) {
  const key = normalizeToken(environment);

  if (key === 'night') {
    return {
      background: '#1f2937',
      fog: '#2b3646',
      hemiSky: '#4f7db8',
      hemiGround: '#1e293b',
      hemiIntensity: 0.42,
      sunColor: '#9cc7ff',
      sunIntensity: 0.82,
      sunPosition: [7.5, 9.2, 6.1],
      fillColor: '#3b82f6',
      fillIntensity: 0.3,
      fillPosition: [-6.8, 4.2, -6.2],
      exposure: 0.9,
      skyTint: '#223249',
    };
  }

  if (key === 'sunset') {
    return {
      background: '#f4d9c4',
      fog: '#ead0bd',
      hemiSky: '#ffe7c8',
      hemiGround: '#b6a58f',
      hemiIntensity: 1.1,
      sunColor: '#ffd4a1',
      sunIntensity: 2.05,
      sunPosition: [8.8, 8.9, 5.2],
      fillColor: '#ffcc9f',
      fillIntensity: 0.66,
      fillPosition: [-8.1, 4.6, -7.1],
      exposure: 1.12,
      skyTint: '#f3caa6',
    };
  }

  return {
    background: '#dce9f6',
    fog: '#d8e3ef',
    hemiSky: '#f8fbff',
    hemiGround: '#9eabbb',
    hemiIntensity: 1.25,
    sunColor: '#fff5e6',
    sunIntensity: 1.8,
    sunPosition: [9.5, 11.5, 6.8],
    fillColor: '#d7e7ff',
    fillIntensity: 0.85,
    fillPosition: [-8.5, 4.8, -7.2],
    exposure: 1.05,
    skyTint: '#d5e8fb',
  };
}

export function WindowViewer3D({ width, height, color, environment = 'day' }) {
  const mountRef = useRef(null);
  const sceneRef = useRef(null);
  const rendererRef = useRef(null);
  const cameraRef = useRef(null);
  const controlsRef = useRef(null);
  const frameRef = useRef(null);
  const lightsRef = useRef({ hemi: null, sun: null, fill: null, sky: null });
  const animationRef = useRef(0);

  useEffect(() => {
    const mountNode = mountRef.current;
    if (!mountNode) return undefined;

    const preset = getEnvironmentPreset(environment);

    const scene = new THREE.Scene();
    scene.background = new THREE.Color(preset.background);
    scene.fog = new THREE.Fog(preset.fog, 16, 58);

    const camera = new THREE.PerspectiveCamera(42, mountNode.clientWidth / mountNode.clientHeight, 0.1, 120);
    camera.position.set(4.3, 2.1, 7.1);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(mountNode.clientWidth, mountNode.clientHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = preset.exposure;
    mountNode.appendChild(renderer.domElement);

    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.minDistance = 3.4;
    controls.maxDistance = 14;
    controls.maxPolarAngle = Math.PI / 2.03;
    controls.target.set(0, 0.18, 0.05);

    const hemiLight = new THREE.HemisphereLight(preset.hemiSky, preset.hemiGround, preset.hemiIntensity);
    scene.add(hemiLight);

    const sunLight = new THREE.DirectionalLight(preset.sunColor, preset.sunIntensity);
    sunLight.position.set(...preset.sunPosition);
    sunLight.castShadow = true;
    sunLight.shadow.mapSize.set(2048, 2048);
    sunLight.shadow.camera.near = 0.5;
    sunLight.shadow.camera.far = 60;
    sunLight.shadow.camera.left = -16;
    sunLight.shadow.camera.right = 16;
    sunLight.shadow.camera.top = 16;
    sunLight.shadow.camera.bottom = -16;
    sunLight.shadow.bias = -0.00012;
    scene.add(sunLight);

    const fillLight = new THREE.DirectionalLight(preset.fillColor, preset.fillIntensity);
    fillLight.position.set(...preset.fillPosition);
    scene.add(fillLight);

    addEnvironment(scene);

    // Add simple decor props to make the composition feel like a staged architectural shot.
    const decorMaterial = new THREE.MeshStandardMaterial({ color: '#f3f4f6', roughness: 0.92, metalness: 0.02 });
    const tableTop = new THREE.Mesh(new THREE.BoxGeometry(2.2, 0.08, 1.2), decorMaterial);
    tableTop.position.set(2.3, -0.85, 1.95);
    tableTop.castShadow = true;
    tableTop.receiveShadow = true;
    scene.add(tableTop);

    const tableLegMat = new THREE.MeshStandardMaterial({ color: '#c7a97f', roughness: 0.75, metalness: 0.08 });
    const legA = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.9, 0.16), tableLegMat);
    legA.position.set(1.9, -1.25, 1.62);
    legA.castShadow = true;
    legA.receiveShadow = true;
    scene.add(legA);

    const legB = legA.clone();
    legB.position.set(2.7, -1.25, 2.28);
    scene.add(legB);

    const lampPole = new THREE.Mesh(
      new THREE.CylinderGeometry(0.03, 0.03, 1.7, 14),
      new THREE.MeshStandardMaterial({ color: '#d1d5db', roughness: 0.35, metalness: 0.68 })
    );
    lampPole.position.set(3.6, -0.55, 1.1);
    lampPole.castShadow = true;
    lampPole.receiveShadow = true;
    scene.add(lampPole);

    const lampHead = new THREE.Mesh(
      new THREE.SphereGeometry(0.22, 16, 16),
      new THREE.MeshStandardMaterial({ color: '#f8fafc', roughness: 0.38, metalness: 0.08 })
    );
    lampHead.position.set(3.6, 0.34, 1.35);
    lampHead.castShadow = true;
    lampHead.receiveShadow = true;
    scene.add(lampHead);

    lightsRef.current = {
      hemi: hemiLight,
      sun: sunLight,
      fill: fillLight,
      sky: scene.children.find((child) => child.geometry && child.geometry.type === 'SphereGeometry') || null,
    };

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
    const renderer = rendererRef.current;
    const lights = lightsRef.current;
    if (!scene || !renderer || !lights.hemi || !lights.sun || !lights.fill) return;

    const preset = getEnvironmentPreset(environment);
    scene.background = new THREE.Color(preset.background);
    scene.fog = new THREE.Fog(preset.fog, 16, 58);
    renderer.toneMappingExposure = preset.exposure;

    lights.hemi.color.set(preset.hemiSky);
    lights.hemi.groundColor.set(preset.hemiGround);
    lights.hemi.intensity = preset.hemiIntensity;

    lights.sun.color.set(preset.sunColor);
    lights.sun.intensity = preset.sunIntensity;
    lights.sun.position.set(...preset.sunPosition);

    lights.fill.color.set(preset.fillColor);
    lights.fill.intensity = preset.fillIntensity;
    lights.fill.position.set(...preset.fillPosition);

    if (lights.sky && lights.sky.material && lights.sky.material.color) {
      lights.sky.material.color.set(preset.skyTint);
    }
  }, [environment]);

  useEffect(() => {
    const scene = sceneRef.current;
    if (!scene) return;

    const widthScale = clamp((Number(width) || 160) / 100, 0.9, 3.2);
    const heightScale = clamp((Number(height) || 120) / 100, 0.8, 2.8);

    if (frameRef.current) {
      scene.remove(frameRef.current);
      disposeGroup(frameRef.current);
    }

    const installation = createInstallationGroup(widthScale, heightScale, color);
    frameRef.current = installation;
    scene.add(installation);

    const controls = controlsRef.current;
    if (controls) {
      controls.target.set(0, clamp((heightScale - 1.2) * 0.14, -0.06, 0.2), 0.05);
      controls.update();
    }
  }, [width, height, color]);

  return <div className="viewer-canvas" ref={mountRef} />;
}
