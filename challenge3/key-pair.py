import json
def check_dic(n):
    if isinstance(n, dict):
        return True
    else:
        print("The input is not a dictionary.")
        return False


def get_value(nested_obj, key):
    try:
        obj_dict = json.loads(nested_obj)
        keys = key.split("/")
        value = obj_dict
        for k in keys:
            if check_dic(value) is True:
                value = value.get(k)
            else:
                value = None
                break
        return value
    except json.JSONDecodeError:
        print("Invalid input. Please enter a valid JSON-formatted string.") 
    


if __name__ == '__main__': 
    nested_obj = input ("Enter the nested obj : ")
    keys = input ("Enter the keys : ")
    y_value = get_value(nested_obj, keys)
    print(f"The value of the key {keys} is {y_value}")
