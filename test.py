from platformio.project.config import ProjectConfig
import json

class TupleEncoder(json.JSONEncoder):
	def default(self, obj):
		print("COUCOU")
		if isinstance(obj, tuple):
			return {'isTuple': True}
		return super().default(obj)

#print(json.dumps(ProjectConfig().as_tuple(), cls=TupleEncoder))
print(TupleEncoder().encode(ProjectConfig().as_tuple()))
