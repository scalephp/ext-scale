namespace Scale\Http\HTTP\IO;

use Scale\Kernel\Core\Environment;
use Scale\Http\HTTP\IO\Provider\Request;

class RequestFactory
{
    public function factory(<Environment> $env)
    {
        return new Request($env);
    }
}
