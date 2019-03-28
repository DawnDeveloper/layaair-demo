package LayaAir3D_Physics {
	import laya.d3.core.Camera;
	import laya.d3.core.MeshSprite3D;
	import laya.d3.core.Sprite3D;
	import laya.d3.core.light.DirectionLight;
	import laya.d3.core.material.BlinnPhongMaterial;
	import laya.d3.core.scene.Scene3D;
	import laya.d3.math.Vector3;
	import laya.d3.math.Vector4;
	import laya.d3.math.Matrix4x4;
	import laya.d3.physics.PhysicsCollider;
	import laya.d3.physics.Rigidbody3D;
	import laya.d3.physics.shape.BoxColliderShape;
	import laya.d3.physics.shape.CapsuleColliderShape;
	import laya.d3.physics.shape.SphereColliderShape;
	import laya.d3.resource.models.PrimitiveMesh;
	import laya.display.Stage;
	import laya.events.KeyBoardManager;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import laya.webgl.resource.Texture2D;
	
	public class PhysicsWorld_TriggerAndCollisionEvent {
		
		private var scene:Scene3D;
		private var camera:Camera;
		private var kinematicSphere:Sprite3D;
		
		private var translateW:Vector3 = new Vector3(0, 0, -0.2);
		private var translateS:Vector3 = new Vector3(0, 0, 0.2);
		private var translateA:Vector3 = new Vector3(-0.2, 0, 0);
		private var translateD:Vector3 = new Vector3(0.2, 0, 0);
		private var translateQ:Vector3 = new Vector3(-0.01, 0, 0);
		private var translateE:Vector3 = new Vector3(0.01, 0, 0);
		
		private var tmpVector:Vector3 = new Vector3(0, 0, 0);
		
		public function PhysicsWorld_TriggerAndCollisionEvent() {
			//初始化引擎
			Laya3D.init(0, 0);
			Laya.stage.scaleMode = Stage.SCALE_FULL;
			Laya.stage.screenMode = Stage.SCREEN_NONE;
			//显示性能面板
			Stat.show();
			
			//创建场景
			scene = new Scene3D();
			Laya.stage.addChild(scene);
			
			//创建相机
			camera = new Camera(0, 0.1, 100);
			scene.addChild(camera);
			camera.transform.translate(new Vector3(0, 8, 18));
			camera.transform.rotate(new Vector3(-30, 0, 0), true, false);
			camera.clearColor = null;
			
			//创建相机
			var directionLight = new DirectionLight();
			scene.addChild(directionLight);
			directionLight.color = new Vector3(1, 1, 1);
			//设置平行光的方向
			var mat:Matrix4x4 = directionLight.transform.worldMatrix;
			mat.setForward(new Vector3(-1.0, -1.0, 1.0));
			directionLight.transform.worldMatrix=mat;
			
			//创建地面
			var plane:MeshSprite3D = scene.addChild(new MeshSprite3D(PrimitiveMesh.createPlane(20, 20, 10, 10))) as MeshSprite3D;
			//创建BlinnPhong材质
			var planeMat:BlinnPhongMaterial = new BlinnPhongMaterial();
			//加载纹理
			Texture2D.load("res/threeDimen/Physics/wood.jpg", Handler.create(null, function(tex:Texture2D):void {
				planeMat.albedoTexture = tex;
			}));
			//设置材质
			planeMat.tilingOffset = new Vector4(2, 2, 0, 0);
			plane.meshRenderer.material = planeMat;
			
			//创建物理碰撞
			var staticCollider:PhysicsCollider = plane.addComponent(PhysicsCollider) as PhysicsCollider;
			//创建盒型碰撞器
			var boxShape:BoxColliderShape = new BoxColliderShape(20, 0, 20);
			//为物理碰撞设置碰撞形状
			staticCollider.colliderShape = boxShape;
			//创建运动学物体
			addKinematicSphere();
			for (var i:int = 0; i < 30; i++) {
				addBoxAndTrigger();
				addCapsuleCollision();
			}
		}
		
		public function addKinematicSphere():void {
			//创建BlinnPhong材质
			var mat2:BlinnPhongMaterial = new BlinnPhongMaterial();
			//加载纹理
			Texture2D.load("res/threeDimen/Physics/plywood.jpg", Handler.create(null, function(tex:Texture2D):void {
				mat2.albedoTexture = tex;
			}));
			//设置材质反照率颜色
			mat2.albedoColor = new Vector4(1.0, 0.0, 0.0, 1.0);
			
			//创建球型MeshSprite3D
			var radius:Number = 0.8;
			var sphere:MeshSprite3D = scene.addChild(new MeshSprite3D(PrimitiveMesh.createSphere(radius))) as MeshSprite3D;
			sphere.meshRenderer.material = mat2;
			var pos:Vector3 = sphere.transform.position;
			pos.setValue(0, 0.8, 0);
			transform.position = pos;
			
			//创建刚体碰撞器
			var rigidBody:Rigidbody3D = sphere.addComponent(Rigidbody3D);
			//创建球形碰撞器
			var sphereShape:SphereColliderShape = new SphereColliderShape(radius);
			//设置刚体碰撞器的碰撞形状为球形
			rigidBody.colliderShape = sphereShape;
			//设置刚体的质量
			rigidBody.mass = 60;
			//设置刚体为运动学，如果为true仅可通过transform属性移动物体,而非其他力相关属性。
			rigidBody.isKinematic = true;
			
			kinematicSphere = sphere;
			//开始始终循环，定时重复执行(基于帧率)，第一个参数为间隔帧数。
			Laya.timer.frameLoop(1, this, onKeyDown);
		}
		
		private function onKeyDown():void {
			KeyBoardManager.hasKeyDown(87) && kinematicSphere.transform.translate(translateW);//W
			KeyBoardManager.hasKeyDown(83) && kinematicSphere.transform.translate(translateS);//S
			KeyBoardManager.hasKeyDown(65) && kinematicSphere.transform.translate(translateA);//A
			KeyBoardManager.hasKeyDown(68) && kinematicSphere.transform.translate(translateD);//D
			KeyBoardManager.hasKeyDown(81) && plane.transform.translate(translateQ);//Q
			KeyBoardManager.hasKeyDown(69) && plane.transform.translate(translateE);//E
		}
		
		public function addBoxAndTrigger():void {
			//创建BlinnPhong材质
			var mat1:BlinnPhongMaterial = new BlinnPhongMaterial();
			Texture2D.load("res/threeDimen/Physics/rocks.jpg", Handler.create(null, function(tex:Texture2D):void {
				mat1.albedoTexture = tex;
			}));
			//设置反照率颜色
			mat1.albedoColor = new Vector4(1.0, 1.0, 1.0, 1.0);
			
			//随机生成坐标
			var sX:int = Math.random() * 0.75 + 0.25;
			var sY:int = Math.random() * 0.75 + 0.25;
			var sZ:int = Math.random() * 0.75 + 0.25;
			//创建盒型MeshSprite3D
			var box:MeshSprite3D = scene.addChild(new MeshSprite3D(PrimitiveMesh.createBox(sX, sY, sZ))) as MeshSprite3D;
			//设置材质
			box.meshRenderer.material = mat1;
			
			var transform:Transform3D = box.transform;
			//设置位置
			var pos:Vector3 = transform.position;
			pos.setValue(Math.random() * 16 - 8, sY / 2, Math.random() * 16 - 8);
			transform.position = pos;
			//设置欧拉角
			var rotationEuler:Vector3 = transform.rotationEuler;
			rotationEuler.setValue(0, Math.random() * 360, 0);
			transform.rotationEuler = rotationEuler;
			
			//创建物理碰撞器
			var staticCollider:PhysicsCollider = box.addComponent(PhysicsCollider);//StaticCollider可与非Kinematic类型RigidBody3D产生碰撞
			//创建盒型碰撞器
			var boxShape:BoxColliderShape = new BoxColliderShape(sX, sY, sZ);
			staticCollider.colliderShape = boxShape;
			//标记为触发器,取消物理反馈
			staticCollider.isTrigger = true;
			//添加触发器组件脚本
			var script:TriggerCollisionScript = box.addComponent(TriggerCollisionScript);
			script.kinematicSprite = kinematicSphere;
		}
		
		public function addCapsuleCollision():void {
			var mat3:BlinnPhongMaterial = new BlinnPhongMaterial();
			Texture2D.load("res/threeDimen/Physics/wood.jpg", Handler.create(null, function(tex:Texture2D):void {
				mat3.albedoTexture = tex;
			}));
			
			var raidius:int = Math.random() * 0.2 + 0.2;
			var height:int = Math.random() * 0.5 + 0.8;
			var capsule:MeshSprite3D = scene.addChild(new MeshSprite3D(PrimitiveMesh.createCapsule(raidius, height))) as MeshSprite3D;
			capsule.meshRenderer.material = mat3;

			var transform:Transform3D = capsule.transform;
			//设置位置
			var pos:Vector3 = transform.position;
			pos.setValue(Math.random() * 4 - 2, 2, Math.random() * 4 - 2);
			transform.position = pos;
			//设置欧拉角
			var rotationEuler:Vector3 = transform.rotationEuler;
			rotationEuler.setValue(Math.random() * 360, Math.random() * 360, Math.random() * 360);
			transform.rotationEuler = rotationEuler;
			
			var rigidBody:Rigidbody3D = capsule.addComponent(Rigidbody3D);//Rigidbody3D可与StaticCollider和RigidBody3D产生碰撞
			var sphereShape:CapsuleColliderShape = new CapsuleColliderShape(raidius, height);
			rigidBody.colliderShape = sphereShape;
			rigidBody.mass = 10;
			var script:TriggerCollisionScript = capsule.addComponent(TriggerCollisionScript);
			script.kinematicSprite = kinematicSphere;
		
		}
		
		public function addSphere():void {
			var mat2:BlinnPhongMaterial = new BlinnPhongMaterial();
			Texture2D.load("res/threeDimen/Physics/plywood.jpg", Handler.create(null, function(tex:Texture2D):void {
				mat2.albedoTexture = tex;
			}));
			
			var radius:Number = Math.random() * 0.2 + 0.2;
			var sphere:MeshSprite3D = scene.addChild(new MeshSprite3D(PrimitiveMesh.createSphere(radius))) as MeshSprite3D;
			sphere.meshRenderer.material = mat2;
			var pos:Vector3 = sphere.transform.position;
			pos.setValue(Math.random() * 4 - 2, 10, Math.random() * 4 - 2);
			sphere.transform.position = pos;
			
			var rigidBody:Rigidbody3D = sphere.addComponent(Rigidbody3D);
			var sphereShape:SphereColliderShape = new SphereColliderShape(radius);
			rigidBody.colliderShape = sphereShape;
			rigidBody.mass = 10;
		}
	}
}

import laya.d3.component.Script3D;
import laya.d3.core.MeshRenderer;
import laya.d3.core.MeshSprite3D;
import laya.d3.core.Sprite3D;
import laya.d3.core.material.BlinnPhongMaterial;
import laya.d3.math.Vector4;
import laya.d3.physics.Collision;
import laya.d3.physics.PhysicsComponent;

class TriggerCollisionScript extends Script3D {
	public var kinematicSprite:Sprite3D;
	
	public function TriggerCollisionScript() {
	
	}
	
	//开始触发时执行
	override public function onTriggerEnter(other:PhysicsComponent):void {
		(((owner as MeshSprite3D).meshRenderer as MeshRenderer).sharedMaterial as BlinnPhongMaterial).albedoColor = new Vector4(0.0, 1.0, 0.0, 1.0);
		trace("onTriggerEnter");
	}
	
	//持续触发时执行
	override public function onTriggerStay(other:PhysicsComponent):void {
		trace("onTriggerStay");
	}
	
	//结束触发时执行
	override public function onTriggerExit(other:PhysicsComponent):void {
		(((owner as MeshSprite3D).meshRenderer as MeshRenderer).sharedMaterial as BlinnPhongMaterial).albedoColor = new Vector4(1.0, 1.0, 1.0, 1.0);
		trace("onTriggerExit");
	}
	
	//开始碰撞时执行
	override public function onCollisionEnter(collision:Collision):void {
		if (collision.other.owner === kinematicSprite)
			(((owner as MeshSprite3D).meshRenderer as MeshRenderer).sharedMaterial as BlinnPhongMaterial).albedoColor = new Vector4(0.0, 0.0, 0.0, 1.0);
	}
	
	//持续碰撞时执行
	override public function onCollisionStay(collision:Collision):void {
	}
	
	//结束碰撞时执行
	override public function onCollisionExit(collision:Collision):void {
	}

}