import com.gEngine.display.Camera;
import com.gEngine.display.Layer;
import gameObjects.Marco;

typedef GGD = GlobalGameData; 
class GlobalGameData {

    public static var marco:Marco;
    public static var simulationLayer:Layer;

    public static function destroy() {
        marco=null;
        simulationLayer=null;
    }
}