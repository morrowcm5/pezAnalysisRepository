function varargout = cbkswitch(varargin)

if (nargout == 0)
  feval(varargin{:});
else
  [varargout{1:nargout}] = feval(varargin{:});
end