namespace Scale\Http\HTTP\IO\Provider;

use Scale\Http\HTTP\IO\RequestInterface;
use Scale\Kernel\Core\Environment;
use Scale\Kernel\Core\RuntimeException;

class Request implements RequestInterface
{
    protected $env;
    protected $uri;
    protected $params;
    protected $method;
    protected $body;

    /**
     *
     * @param Environment $env
     */
    public function __construct(<Environment> $env)
    {
        let this->env = $env;

        this->setup();
    }

    /**
     *
     */
    public function setup()
    {
        let this->uri = strtok(this->env->getServer("REQUEST_URI"), '?');

        let this->method = this->env->getServer("REQUEST_METHOD");

        let this->body = file_get_contents("php://input");
    }

    /**
     *
     * @param  string $name
     * @return string
     * @throws RuntimeException
     */
    public function param(string $name)
    {
        if (this->method === "POST") {
            return filter_input(INPUT_POST, $name, FILTER_SANITIZE_STRING);
        } elseif (this->method === "GET") {
            return filter_input(INPUT_GET, $name, FILTER_SANITIZE_STRING);
        } else {
            throw new RuntimeException("Invalid Param Request");
        }
    }

    public function uri()
    {
        return this->uri;
    }

    /**
     *
     * @return array
     * @throws RuntimeException
     */
    public function params()
    {
        var $input;
        if (this->method === "POST") {
            let $input = INPUT_POST;
        } elseif (this->method === "GET") {
            let $input = INPUT_GET;
        } else {
            throw new RuntimeException("Invalid Param Request");
        }
        return filter_input_array($input, FILTER_SANITIZE_STRING);
    }
}
