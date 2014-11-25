namespace Scale\Kernel\Core;

/**
 * DI Builders
 *
 * Used to provide classes a generic container and transfer methods for
 * dependencies and instances.
 *
 * @package    Kernel
 * @category   Base
 * @author     Scale Team
 */

use Closure;
use ReflectionParameter;
use Scale\Kernel\Interfaces\BuilderInterface;
use Scale\Kernel\Core\RuntimeException;

class Container
{
    /**
     * Closures used to build classes
     *
     * @var array
     */
    protected $builders;

    /**
     * Instance variables
     *
     * @var array
     */
    protected $instances;


    protected app_path = "";


    public function __construct(string app_path)
    {
        let this->app_path = app_path;
        this->loadBuilders();
    }


    /**
     * Returns a named value from $instances, if not set then returns the
     * builder for that key
     *
     * @param string $name
     * @return mixed
     */
    public function __get(string $name)
    {
        if (isset(this->instances[$name])) {
            return this->instances[$name];
        }
        return this->getBuilder($name);
    }

    /**
     * Sets a builder Closure or instance value for a given key
     *
     * @param string $name
     * @param mixed  $value
     */
    public function __set(string $name, var $value)
    {
        if ($value instanceof \Closure) {

            this->setBuilder($name, $value);
        } else {

            this->setInstance($name, $value);
        }
    }

    /**
     * If its present in instances, return it, else call its builder
     * to create a new instance
     *
     * @param string $name
     * @param array  $arguments
     * @return mixed
     */
    public function __call($name, $arguments)
    {
        // Do we have this object in store as an instance already?
        if (isset(this->instances[$name]) && !$arguments) {
            return this->instances[$name];
        }

        /**
         * Intercept the build prefix and automatically generate the requested
         * resource.
         * 
         * $object->buildClient()  --> creates a "client"
         * $driver->buildAdaptor() --> creates a "adaptor"
         * 
         * Uses factories defined in builders.php config file
         */
        if (substr($name, 0, 5) == "build") {
            return this->newInstance(strtolower(substr($name, 5)), $arguments);
        }

        // Call a builder with the same name as the __call() method
        return this->callBuilder($name, $arguments);
    }

    /**
     * Gets a builder closure for a given key
     * 
     * @param string $name
     * @return \Closure
     */
    public function getBuilder(string $name)
    {
        if (isset(this->builders[$name])) {
            return this->builders[$name];
        }
    }

    /**
     * Sets the builder closure for a given key
     * 
     * @param string   $name
     * @param \Closure $builder
     * @return mixed
     */
    public function setBuilder(string $name, <Closure> $builder)
    {
        let this->builders[$name] = $builder;

        return this;
    }

    /**
     * Invokes a builder with the given key and parameters
     * 
     * @param string $name
     * @param array  $params
     * @return mixed
     */
    public function callBuilder(string $name, array $params = [])
    {
        if (isset(this->builders[$name])) {
            return call_user_func_array(this->builders[$name], $params);
        }
        var_dump(this->builders);
        throw new RuntimeException("Call to undefind method ".$name);
    }

    /**
     * Sets a variable to the instance storage
     * 
     * @param string $name
     * @param mixed  $instance
     * @return BuilderInterface
     */
    public function setInstance(string $name, var $instance)
    {
        let this->instances[$name] = $instance;
        return this;
    }

    /**
     * Creates and sets a new instace of a builder
     * 
     * @param string $name
     * @param array  $params
     */
    public function newInstance(string $name, array $params = [])
    {
        return this->setInstance($name, this->callBuilder($name, $params));
    }

    /**
     * Sets a resource instance to the object
     * 
     * @param BuilderInterface  $consumer
     * @param string $builder
     * @param mixed  $instance
     */
    public function provide(<BuilderInterface> $consumer, string $builder, var $instance = null)
    {
        if ($instance !== null) {
            $consumer->setInstance($builder, $instance);
        } else {
            $consumer->setBuilder($builder, this->builders[$builder]);
        }
    }

    /**
     * Return classes required in the given class' constructor
     * @param  bool $lowercase
     * @return array
     */
    public function reflectConstruct(bool $lowercase = true)
    {
        var $params, $param;
        string $name;
        var classes;
        let classes = [];
        let $params = (new \ReflectionClass(this))->getConstructor()->getParameters();

        for $param in $params {
            let $name = $param->getClass()->name;
            let classes[] = ($lowercase) ? strtolower($name) : $name;
        }
        return classes;
    }

    /**
     * Automatically injects dependencies into a new object's constructor
     * and returns the new instance.
     * 
     * @param string class
     * @return object
     */
    public function constructInject(string $class)
    {
        // Get the $class' reflection
        var reflection, dependencies, constructor, param, local;
        let $reflection = new \ReflectionClass($class);
        
        // Array to hold dependencies to inject
        let $dependencies = [];
        
        // Get the __construct() method of the given class
        let $constructor = $reflection->getConstructor();
        
        // If no constructor, no dependencies, easy, just instantiate
        if (!$constructor) {
            return $reflection->newInstanceWithoutConstructor();
        }
        
        // If we have parameters, let's cycle through them
        for $param in $constructor->getParameters() {
            
            // Check if we can build this locally
            let $local = this->getLocalValue($param);
            
            // If found locally
            if (is_object($local)) {
                let $dependencies[] = $local;
            
            // Else, let's instantiate via autoloader
            } elseif($param->getClass()) {
                let $dependencies[] = $param->getClass()->newInstance();
                
            // If it isn't an object, let's check for a default scalar
            } elseif ($param->isDefaultValueAvailable()) {
                let $dependencies[] = $param->getDefaultValue();
                
            // If no default value availble, check if it's optional
            } elseif ($param->isOptional()) {
                let $dependencies[] = null;
                
            // We can't build this class correctly, fail    
            } else {
                throw new RuntimeException("Unable to resolve parameter");
            }
        }
        
        // Create and return new instance with given dependencies
        return $reflection->newInstanceArgs($dependencies);
    }

    /**
     * When constructInject()'ing a class, this method is called to determine if
     * the dependency can be created with builder definitions
     * 
     * @param ReflectionParameter $param
     * @return mixed
     */
    protected function getLocalValue(<ReflectionParameter> $param)
    {
        var $class, local;
        let $class = $param->getClass();
        
        // Do we need a Closure returned?
        if ($class->name == "Closure") {

            // Get from trait's parent object
            let local = this->__get($param->name);
        
        // We need an instance, not a builder
        } else {
            
            let local = this->__get(strtolower($class->name));
            
            // If we have a local builder, execute it to get a new instance
            if (local instanceof Closure) {

                let local = call_user_func(local);
            }
        }
        return local;
    }

    /**
     * 
     * @param string $name
     * @return array
     */
    protected function appConfig(string $name)
    {
        return require this->app_path."/etc/".$name.".php";
    }

    /**
     *  Container of Builder Closures
     *
     *  [
     *    'object' => function ($type) { return new Concrete($type, ..);},
     *    'foobar' => function () { return new FoobarType();},
     *    '' => ''...
     *  ]
     */
    protected function loadBuilders()
    {
        let this->builders = this->appConfig("builders");
        echo this->app_path;
    }
}
