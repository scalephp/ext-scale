namespace Scale\Http\HTTP;

use Scale\Kernel\Interfaces\BuilderInterface;
use Scale\Kernel\Core\Container;

class ControllerFactory extends Container implements BuilderInterface
{
    public function factory($name)
    {
        if (class_exists($name)) {
           
            return this->constructInject($name);
        }
    }
}
