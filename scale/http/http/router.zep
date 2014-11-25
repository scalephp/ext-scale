namespace Scale\Http\HTTP;

use Closure;
use Scale\Kernel\Interfaces\ExecutorInterface;
use Scale\Kernel\Core\Builders;
use Scale\Kernel\Core\RuntimeException;
use Scale\Http\HTTP\IO\RequestInterface;

class Router implements ExecutorInterface
{
    protected request;
    protected controller;
    protected route;

    /**
     *
     * @param string $uri
     * @param array  $params
     * @param RequestInterface $request
     * @param Closure $controller
     */
    public function __construct(<RequestInterface> $request = null, <\Closure> $controller = null)
    {
        let this->request = $request;
        let this->controller = $controller;
    }

    /**
     *
     * @return Router
     */
    public function prepare()
    {
        // Find route in config
        let this->route = this->getRoute(this->request->uri(), this->request->params());

        // Create a new instance of the task
        let this->controller = this->controller->__invoke(this->route["controller"]);

        return this;
    }

    /**
     *
     * @param  string $uri
     * @param  array  $params
     * @return array
     * @throws RuntimeException
     */
    public function getRoute(string $uri, var $params)
    {
        var $routes, $route, $param;
        array $input;
        let route = null;
        let $routes = apc_fetch("routes");
        if (!$routes)
        {
            let $routes = (array) require dirname(dirname(_SERVER["DOCUMENT_ROOT"]))."/etc/routes.php";
            apc_store("routes", $routes);
        }

        if (isset($routes[$uri])) {
            let $route = $routes[$uri];
        } else {
            throw new RuntimeException("404");
        }

        let $input = [];

        for $param in $route["params"] {
            let $input[$param] = isset($params[$param]) ? $params[$param] : null;
        }

        let $route["input"] = $input;
        return $route;
    }

    /**
     * Executes the controller action
     */
    public function execute()
    {
        return call_user_func_array(
            [this->controller, this->route["action"]],
            this->route["input"]
        );
    }
}
