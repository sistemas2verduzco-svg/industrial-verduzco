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
    scene.background = new THREE.Color('#e8edf2');

    const camera = new THREE.PerspectiveCamera(40, mountNode.clientWidth / mountNode.clientHeight, 0.1, 100);
    camera.position.set(4, 3, 6);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(mountNode.clientWidth, mountNode.clientHeight);
    renderer.shadowMap.enabled = true;
    mountNode.appendChild(renderer.domElement);

    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.minDistance = 4;
    controls.maxDistance = 12;
    controls.maxPolarAngle = Math.PI / 2.02;

    const ambientLight = new THREE.AmbientLight('#ffffff', 1.8);
    scene.add(ambientLight);

    const spotLight = new THREE.SpotLight('#ffffff', 2.2, 100, 0.45);
    spotLight.position.set(10, 14, 12);
    spotLight.castShadow = true;
    scene.add(spotLight);

    const fillLight = new THREE.DirectionalLight('#dbeafe', 1.1);
    fillLight.position.set(-6, 6, -4);
    scene.add(fillLight);

    const floor = new THREE.Mesh(
      new THREE.CircleGeometry(8, 48),
      new THREE.MeshStandardMaterial({ color: '#d9e1e8', roughness: 0.95, metalness: 0.02 })
    );
    floor.rotation.x = -Math.PI / 2;
    floor.position.y = -1.8;
    floor.receiveShadow = true;
    scene.add(floor);

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
      roughness: 0.42,
      metalness: 0.35,
    });

    const glassMaterial = new THREE.MeshPhysicalMaterial({
      color: '#dbeafe',
      metalness: 0.02,
      roughness: 0.08,
      transmission: 0.7,
      transparent: true,
      opacity: 0.5,
      thickness: 0.08,
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

    group.add(leftFrame, rightFrame, topFrame, bottomFrame, centerRail, leftGlass, rightGlass, sill);
    group.position.y = 0.1;
    frameRef.current = group;
    scene.add(group);
  }, [width, height, color]);

  return <div className="viewer-canvas" ref={mountRef} />;
}
